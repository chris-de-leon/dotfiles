{
  # https://github.com/NixOS/nixpkgs/commits/master
  inputs = {
    nixpkgs.url = "https://github.com/NixOS/nixpkgs/archive/be77f97455fc7f17d3deabe790d7a7a1c3cdd899.tar.gz";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        dotfiles = import ./default.nix { inherit pkgs; };
      in
      rec {
        formatter = pkgs.nixpkgs-fmt;

        devShell = pkgs.mkShell rec {
          DOTFILES_DIR = "${pkgs.lib.strings.removePrefix "/nix/store/" "${dotfiles}"}";
          DOTFILES_REL = ".config/dotfiles/chris-de-leon/${DOTFILES_DIR}";
          DOTFILES_DST = "${"$"}HOME/${DOTFILES_REL}";
          DOTFILES_SRC = "${dotfiles}";

          # Configures starship to use our custom configs:
          #  - https://starship.rs/config/#configuration
          #
          wrappedStarship = pkgs.symlinkJoin {
            name = "starship";
            paths = [ pkgs.starship ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/starship \
                --run "export STARSHIP_CONFIG=\$HOME/${DOTFILES_REL}/starship.toml"
            '';
          };

          # Configures tmux to use our custom configs:
          #  - https://unix.stackexchange.com/a/663023
          #  - https://askubuntu.com/a/746846
          #
          wrappedTmux = pkgs.symlinkJoin {
            name = "tmux";
            paths = [ pkgs.tmux ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/tmux \
                --add-flags "-u" \
                --add-flags "-f" \
                --add-flags "\$HOME/${DOTFILES_REL}/tmux.conf"
            '';
          };

          # Configures neovim to use our custom configs:
          #  - https://vi.stackexchange.com/questions/37639/viminit-conflicts-for-neovim-and-vim
          #  - https://neovim.io/doc/user/starting.html#initialization
          #  - https://stackoverflow.com/a/75633317
          #
          wrappedNvim = pkgs.symlinkJoin {
            name = "nvim";
            paths = [ pkgs.neovim ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/nvim \
                --run "export XDG_CONFIG_HOME=\$HOME/${DOTFILES_REL}" \
                --set "NVIM_APPNAME" "nvim"
            '';
          };

          packages = [
            wrappedStarship
            pkgs.unzipNLS
            pkgs.ripgrep
            pkgs.lazygit
            wrappedNvim
            wrappedTmux
            pkgs.vim
            pkgs.fd
            pkgs.jq
          ];

          shellHook = ''
            if [ ! -d ${DOTFILES_DST} ]; then
              # Create a folder to store the dotfiles
              mkdir -p ${DOTFILES_DST}

              # All files in /nix/store are readonly: https://nix.dev/manual/nix/2.23/installation/multi-user#multi-user-mode 
              # This is problematic because some programs (e.g. neovim) need to write to them to ensure things are configured 
              # properly. To get around this we'll copy the files from /nix/store, reset their permissions, and store them in 
              # the destination folder, which should be writable
              cp --no-preserve=mode -r ${DOTFILES_SRC}/* ${DOTFILES_DST}

              # Configure tmux to use an interactive non-login shell that sources the wrapper bashrc file:
              #
              #  - https://discourse.nixos.org/t/interactive-bash-with-nix-develop-flake/15486
              #  - https://unix.stackexchange.com/a/98085
              #  - https://unix.stackexchange.com/a/541352
              #  - https://stackoverflow.com/a/45389462
              #
              if ! grep -q 'set-option -g default-command' "${DOTFILES_DST}/tmux.conf"; then
                echo "set-option -g default-command \"${pkgs.bashInteractive}/bin/bash --rcfile \"${DOTFILES_DST}/bashrc\"\"" >> "${DOTFILES_DST}/tmux.conf"
              fi

              # If you're already in a `nix develop` shell session and you start a new nested nix shell with `nix develop`, then
              # Nix will reset PS1, remove any unexported functions that were defined in your previous shell, and remove any env
              # variables that reference unexported functions (e.g. PROMPT_COMMAND). This is problematic because if our previous
              # shell was styled using let's say starship for example, then any command prompt styling that starship has provided
              # wouldn't be carried over to the nested shell session. To fix this, we will use `set -a` and `set +a` so that all 
              # the starship functions we need are exported properly: https://unix.stackexchange.com/a/430690
              export starship_setup_cmd="set -a && eval \"\$(${wrappedStarship}/bin/starship init bash)\" && set +a"
              printf "$starship_setup_cmd" >> "${DOTFILES_DST}/starshiprc"
              printf "$starship_setup_cmd" >> "${DOTFILES_DST}/bashrc"
            fi

            . ${DOTFILES_DST}/starshiprc
          '';
        };
      }
    );
}

{
  # https://github.com/NixOS/nixpkgs/commit/9f4128e00b0ae8ec65918efeba59db998750ead6
  inputs = {
    nixpkgs.url = "https://github.com/NixOS/nixpkgs/archive/9f4128e00b0ae8ec65918efeba59db998750ead6.tar.gz";
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
              --add-flags "${dotfiles}/tmux.conf"
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
              --set "XDG_CONFIG_HOME" "${dotfiles}" \
              --set "NVIM_APPNAME" "nvim"
          '';
        };

        devShell = pkgs.mkShell {
          # NOTE: if you are already in a `nix develop` shell session and you start a new nested nix shell with
          # `nix develop`, then Nix will reset PS1 and remove any unexported functions that were defined in your
          # previous shell. This is problematic because if our previous shell was styled using let's say starship
          # for example, then any shell styling that starship provided would be reset in the nested shell, which
          # is not ideal. To fix this, we can use the PROMPT_COMMAND env variable, which doesn't seem to be reset
          # by Nix:
          #
          #   https://github.com/NixOS/nix/issues/9174#issuecomment-1769023518
          #
          # Initially, we'll configure PROMPT_COMMAND such that it sources our custom bashrc file, which includes the
          # steps needed to configure starship. When we call nix develop for the first time, the PROMPT_COMMAND won't
          # activate immediately (since we haven't run any commands yet), so we also need to source the custom bashrc
          # file in the shellHook so that it is styled once we enter it. When the first command is run in the shell,
          # the PROMPT_COMMAND will get evaluated and it will source the bashrc file. This causes the starship setup
          # commands to be evaluated, which results in PROMPT_COMMAND getting reassigned to one of starship's helper
          # functions. At that point, everything should be working in the current shell. However, to ensure that this
          # styling is maintained for future shells, we need to ensure that the starship function that PROMPT_COMMAND
          # was assigned to (and all the starship helper functions it references) are exported for future shells. To
          # do this, we use `set -a` and `set +a` so that all the functions we need are exported properly.
          #
          #   https://unix.stackexchange.com/a/430690
          #
          PROMPT_COMMAND = "set -a; . ${dotfiles}/bashrc; set +a;";

          # Export the location of the dotfile configs
          DOTFILES_HOME = "${dotfiles}";

          # Add common dev tools
          packages = [
            pkgs.starship
            pkgs.unzipNLS
            pkgs.ripgrep
            pkgs.lazygit
            wrappedNvim
            wrappedTmux
            pkgs.vim
            pkgs.fd
            pkgs.jq
          ];

          # Source the custom bashrc file
          shellHook = ''
            . ${dotfiles}/bashrc
          '';
        };
      }
    );
}

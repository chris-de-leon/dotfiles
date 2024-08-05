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
          DOTFILES_HOME = "${dotfiles}";
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
          shellHook = ''
            . ${dotfiles}/starshiprc
          '';
        };
      }
    );
}

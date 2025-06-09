{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};

        # Configures tmux to use interactive bash with a custom rc file:
        #  - https://unix.stackexchange.com/a/663023
        #  - https://askubuntu.com/a/746846
        wrappedTmux = pkgs.symlinkJoin {
          name = "tmux";
          paths = [pkgs.tmux];
          buildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/tmux \
              --set "SHELL" "${pkgs.bashInteractive}/bin/bash" \
              --add-flags "-u"
          '';
        };

        devenv = pkgs.buildEnv {
          name = "devenv";
          paths = [
            pkgs.bitwarden-cli
            pkgs.shellcheck
            pkgs.unzipNLS
            pkgs.starship
            pkgs.ripgrep
            pkgs.lazygit
            pkgs.gnumake
            pkgs.chezmoi
            pkgs.neovim
            wrappedTmux
            pkgs.gcc
            pkgs.fzf
            pkgs.zip
            pkgs.vim
            pkgs.fd
            pkgs.jq
          ];
        };
      in rec {
        formatter = pkgs.alejandra;

        packages = {
          default = devenv;
          fmt = formatter;
        };
      }
    );
}

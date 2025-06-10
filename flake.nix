{
  inputs = {
    # https://github.com/NixOS/nixpkgs/commits/nixos-25.05/
    nixpkgs.url = "github:NixOS/nixpkgs/70c74b02eac46f4e4aa071e45a6189ce0f6d9265";
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

        # The nix package for the Bitwarden CLI currently has some issues
        # on Darwin (see https://github.com/NixOS/nixpkgs/issues/339576).
        # To get around this, we will run the CLI via npx. Once the issue
        # gets resolved we'll add the bitwarden-cli to the devenv profile
        # again.
        bw =
          if pkgs.stdenv.isDarwin
          then
            pkgs.writeShellApplication {
              name = "bw";
              runtimeInputs = [pkgs.nodejs];
              text = ''npx --yes @bitwarden/cli@2025.4.0 "${"$"}{@:1}"'';
            }
          else pkgs.bitwarden-cli;

        # Configures tmux to use interactive bash:
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
            bw
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

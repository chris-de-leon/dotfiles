{
  inputs = {
    # https://github.com/NixOS/nixpkgs/commits/nixos-25.05/
    nixpkgs.url = "github:NixOS/nixpkgs/ac62194c3917d5f474c1a844b6fd6da2db95077d";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem (
      system: let
        # Helper bindings
        vrsn = builtins.replaceStrings ["\n"] [""] (builtins.readFile ./VERSION);
        pkgs = import nixpkgs {inherit system;};
        etcd = "etc/profile.d";

        # A simple CLI tool for managing the dev environment
        # Source: https://github.com/NixOS/nixpkgs/blob/ec36eadef0d12bcb98ce2946875198dbddcb7794/pkgs/build-support/trivial-builders/default.nix#L246
        devkit = pkgs.writeShellApplication {
          name = "devkit";
          text = builtins.readFile ./cli/main.sh;
          runtimeInputs = [pkgs.stow];
          bashOptions = []; # bash options are already defined in the script
          runtimeEnv = {
            DEVKIT_INIT = "${etcd}/${init.name}";
            DEVKIT_VRSN = vrsn;
          };
        };

        # This is the script that should be sourced from ~/.bashrc or ~/.profile to activate the dev environment
        # Source: https://github.com/NixOS/nixpkgs/blob/ec36eadef0d12bcb98ce2946875198dbddcb7794/pkgs/build-support/trivial-builders/default.nix#L246
        init = pkgs.writeShellApplication {
          name = "init";
          text = builtins.readFile ./cli/init.sh;
          runtimeInputs = []; # requires no dependencies
          bashOptions = []; # no options should be added since we're going to source this script
        };

        # Configures tmux to use interactive bash for terminal coloring (see https://unix.stackexchange.com/a/663023 + https://askubuntu.com/a/746846)
        # Source: https://github.com/NixOS/nixpkgs/blob/ec36eadef0d12bcb98ce2946875198dbddcb7794/pkgs/build-support/trivial-builders/default.nix#L576
        tmux = pkgs.symlinkJoin {
          name = "tmux";
          paths = [pkgs.tmux];
          buildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram $out/bin/tmux \
              --set "SHELL" "${pkgs.bashInteractive}/bin/bash" \
              --add-flags "-u"
          '';
        };

        # This adds Neovim and all dependencies needed for LazyVim (see https://www.lazyvim.org/)
        # Source: https://github.com/NixOS/nixpkgs/blob/ec36eadef0d12bcb98ce2946875198dbddcb7794/pkgs/build-support/buildenv/default.nix#L1
        lvim = pkgs.buildEnv {
          name = "lvim";
          paths =
            [
              pkgs.tree-sitter
              pkgs.ripgrep
              pkgs.neovim
              pkgs.unzip # used by mason.nvim
              pkgs.gcc
              pkgs.fzf
              pkgs.fd
            ]
            ++ pkgs.lib.optionals (pkgs.stdenv.isDarwin) [
              pkgs.gnused
            ];
        };

        # This defines the packages that should be included in the development environment
        # Source: https://github.com/NixOS/nixpkgs/blob/ec36eadef0d12bcb98ce2946875198dbddcb7794/pkgs/build-support/buildenv/default.nix#L1
        devenv = pkgs.buildEnv {
          name = "devenv";
          paths = [
            (
              # This copies the init script into the devenv so that it has a stable path and easier to source
              pkgs.runCommand "init" {} ''
                mkdir -p $out/${etcd} && cp ${init}/bin/${init.name} $out/${etcd}/${init.name}
              ''
            )
            pkgs.starship
            pkgs.lazygit
            pkgs.vim
            pkgs.jq
            pkgs.gh
            devkit
            lvim
            tmux
          ];
        };
      in {
        formatter = pkgs.alejandra;
        packages = {
          default = devenv;
        };
      }
    );
}

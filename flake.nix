{
  inputs = {
    # https://github.com/NixOS/nixpkgs/commits/nixos-25.05/
    nixpkgs.url = "github:NixOS/nixpkgs/e9b7f2ff62b35f711568b1f0866243c7c302028d";
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
        home = ".local/share/chris-de-leon/dotfiles";
        pkgs = import nixpkgs {inherit system;};
        etcd = "etc/profile.d";
        init = "init";

        # This is the script that should be sourced from ~/.bashrc or ~/.profile to activate the dev environment
        # Source: https://github.com/NixOS/nixpkgs/blob/ec36eadef0d12bcb98ce2946875198dbddcb7794/pkgs/build-support/trivial-builders/default.nix#L246
        initializer = pkgs.writeShellApplication {
          name = init;
          text = builtins.readFile ./pkg/init.sh;
          runtimeInputs = []; # requires no dependencies
          bashOptions = []; # no options should be added since we're going to source this script
        };

        # A custom CLI tool for managing the dev environment
        # Source: https://github.com/NixOS/nixpkgs/blob/ec36eadef0d12bcb98ce2946875198dbddcb7794/pkgs/build-support/trivial-builders/default.nix#L246
        devkit = pkgs.writeShellApplication {
          name = "devkit";
          text = builtins.readFile ./pkg/cli.sh;
          runtimeInputs = []; # packages will be provided by devenv
          bashOptions = []; # already defined in the script
          runtimeEnv = {
            DOTFILES_INIT = "${etcd}/${init}";
            DOTFILES_HOME = home;
            DOTFILES_VRSN = vrsn;
          };
        };

        # Configures tmux to use interactive bash (for terminal coloring) (see https://unix.stackexchange.com/a/663023 + https://askubuntu.com/a/746846)
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

        # This defines the packages that should be included in the development environment
        # Source: https://github.com/NixOS/nixpkgs/blob/ec36eadef0d12bcb98ce2946875198dbddcb7794/pkgs/build-support/buildenv/default.nix#L1
        devenv = pkgs.buildEnv {
          name = "devenv";
          paths =
            [
              (
                pkgs.runCommand "init" {} ''
                  mkdir -p $out/${etcd} && cp ${initializer}/bin/${init} $out/${etcd}/${init}
                ''
              )
              pkgs.tree-sitter # dependency for LazyVim
              pkgs.shellcheck # catch subtle issues with shell scripts faster
              pkgs.starship # terminal coloring + useful info
              pkgs.ripgrep # dependency for LazyVim
              pkgs.lazygit # easier Git management
              pkgs.gnumake # install `make`
              pkgs.neovim # primary coding editor
              pkgs.stow # for symlinking dotfiles
              pkgs.gcc # dependency for LazyVim
              pkgs.fzf # dependency for LazyVim
              pkgs.vim # default editor for Git
              pkgs.fd # dependency for LazyVim
              pkgs.jq # easy JSON handling
              pkgs.gh # take Github to the CLI
              devkit # manage the dev env
              tmux # split windows
            ]
            ++ pkgs.lib.optionals (pkgs.stdenv.isDarwin) [
              pkgs.gnused # dependency for LazyVim
            ];
        };
      in rec {
        formatter = pkgs.alejandra;
        packages = {
          default = devenv;
          devkit = devkit;
          fmt = formatter;
          setup = pkgs.writeShellApplication {
            name = "setup";
            text = builtins.readFile ./pkg/setup.sh;
            runtimeInputs = [devenv];
            bashOptions = []; # already defined in the script
          };
        };
      }
    );
}

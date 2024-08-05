{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs) stdenv;
  bashrc = pkgs.writeText "bashrc" ''
    if [ -f "$HOME/.bashrc" ]; then
      . "$HOME/.bashrc"
    fi
  '';
in
stdenv.mkDerivation {
  name = "dotfiles";
  src = ./configs;
  installPhase = ''
    # Exits early if any command runs into an issue and prints commands as they are executed
    set -ex

    # Copies source files into an output folder
    mkdir -p $out
    cp -v ${bashrc} $out/bashrc
    cp -rv $src/* $out

    # Grants elevated permissions to tmux.conf and bashrc. In the end, these
    # will be given 555 permissions: https://stackoverflow.com/a/61736179
    chmod 777 $out/tmux.conf
    chmod 777 $out/bashrc

    # Add starship setup commands to bashrc
    printf "\nexport STARSHIP_CONFIG=\"$out/starship.toml\" && eval \"\$(starship init bash)\"" >> "$out/bashrc"

    # Configures tmux to use an interactive non-login shell and source our custom bashrc file:
    #
    #  - https://discourse.nixos.org/t/interactive-bash-with-nix-develop-flake/15486
    #  - https://unix.stackexchange.com/a/98085
    #  - https://unix.stackexchange.com/a/541352
    #  - https://stackoverflow.com/a/45389462
    #
    # This code must not be included in the bashrc file! It writes to the tmux config file in /nix/store, so
    # it will cause permission errors: https://nix.dev/manual/nix/2.23/installation/multi-user#multi-user-mode
    #
    if ! grep -q 'set-option -g default-command' "$out/tmux.conf"; then
      echo "set-option -g default-command \"${pkgs.bashInteractive}/bin/bash --rcfile \"$out/bashrc\"\"" >> "$out/tmux.conf"
    fi
  '';
}

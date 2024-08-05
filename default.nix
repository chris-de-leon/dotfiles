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

    # If you are already in a `nix develop` shell session and you start a new nested nix shell with 
    # `nix develop`, then Nix will reset PS1, remove any unexported functions that were defined in 
    # your previous shell, and remove any environment variables that reference unexported functions
    # (e.g. PROMPT_COMMAND). This is problematic because if our previous shell was styled using let's
    # say starship for example, then any command prompt styling that starship provided would not be
    # carried over to the nested shell. To fix this, we'll use `set -a` and `set +a` so that all the
    # starship functions we need are exported properly: https://unix.stackexchange.com/a/430690
    export starship_setup_cmd="export STARSHIP_CONFIG=\"$out/starship.toml\" && set -a && eval \"\$(starship init bash)\" && set +a"
    printf "$starship_setup_cmd" >> "$out/starshiprc"
    printf "$starship_setup_cmd" >> "$out/bashrc"

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

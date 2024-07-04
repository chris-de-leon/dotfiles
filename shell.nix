{ pkgs ? import<nixpkgs> {} }:

let
  conf = import ./configs { inherit pkgs; };
in
pkgs.mkShell {
  buildInputs = [
    # https://discourse.nixos.org/t/interactive-bash-with-nix-develop-flake/15486
    pkgs.bashInteractive # v5.2.26
 
    pkgs.nix-prefetch # v0.4.1
    pkgs.starship # v1.19.0
    pkgs.unzipNLS # v6.0
    pkgs.ripgrep # v14.1.0
    pkgs.lazygit # v0.42.0
    pkgs.neovim # v0.10.0
    pkgs.tmux # v3.4
    pkgs.vim # v9.1
    pkgs.fd # v10.1.0
    pkgs.jq # v1.7.1

    conf
  ];

  shellHook = ''
    # Copy neovim configs
    mkdir -p ~/.config
    rm -rf ~/.config/nvim
    cp -rv ${conf}/nvim ~/.config

    # Configure Starship
    export STARSHIP_CONFIG="${conf}/starship.toml"
    eval "$(starship init bash)"

    # Add helper variables for tmux
    export TMUX_CONFIG="${conf}/tmux.conf"
    export TMUX_SHELL="${pkgs.bashInteractive}/bin/bash"

    # Configure tmux to source ~/.bashrc:
    #  - https://unix.stackexchange.com/a/541352
    #  - https://stackoverflow.com/a/45389462
    #
    if ! grep -q 'set-option -g default-shell' "$TMUX_CONFIG"; then
      echo "set-option -g default-shell \"$TMUX_SHELL\"" >> "$TMUX_CONFIG"
    fi
    if ! grep -q 'set-option -g default-command' "$TMUX_CONFIG"; then
      echo "set-option -g default-command \"$TMUX_SHELL\"" >> "$TMUX_CONFIG"
    fi

    # Add an alias for tmux
    alias tmux="tmux -u -f $TMUX_CONFIG"
  '';
}

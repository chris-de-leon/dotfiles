{ pkgs ? import<nixpkgs> {} }:

# https://github.com/samdroid-apps/nix-articles/blob/master/04-proper-mkderivation.md#using-the-content
let
  inherit (pkgs) stdenv;
in
let
  content = stdenv.mkDerivation {
    name = "dotfiles";
    src = ./configs;
    installPhase = ''
      set -e
      mkdir -p $out
      cp -rv $src/* $out
    '';
  };
in
stdenv.mkDerivation {
  name = "dotfiles-shell";
  buildInputs = [
    # https://discourse.nixos.org/t/interactive-bash-with-nix-develop-flake/15486
    pkgs.bashInteractive
    pkgs.starship
    pkgs.unzipNLS
    pkgs.ripgrep
    pkgs.lazygit
    pkgs.neovim
    pkgs.tmux
    pkgs.vim
    pkgs.fd
    pkgs.jq
  ];
  shellHook = ''
    # Configure neovim:
    #  - https://neovim.io/doc/user/starting.html#initialization
    #  - https://stackoverflow.com/a/75633317
    #  - https://vi.stackexchange.com/questions/37639/viminit-conflicts-for-neovim-and-vim
    #
    alias nvim="XDG_CONFIG_HOME=\"${content}\" NVIM_APPNAME=\"nvim\" nvim"

    # Configure Starship
    export STARSHIP_CONFIG="${content}/starship.toml"
    eval "$(starship init bash)"

    # Add helper variables for tmux
    export TMUX_CONFIG="${content}/tmux.conf"
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

    # Configure tmux
    alias tmux="tmux -u -f \"$TMUX_CONFIG\""
  '';
}

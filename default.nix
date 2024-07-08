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
      chmod 777 $out/starship.toml
      chmod 777 $out/tmux.conf
      chmod 777 $out/bashrc
      cat <<EOT >> $out/bashrc

# Configure tmux to use an interactive non-login shell then have it source our custom bashrc file and use our custom configs:
#  - https://discourse.nixos.org/t/interactive-bash-with-nix-develop-flake/15486
#  - https://unix.stackexchange.com/a/541352
#  - https://stackoverflow.com/a/45389462
#
if ! grep -q 'set-option -g default-command' "$out/tmux.conf"; then
  echo "set-option -g default-command \"${pkgs.bashInteractive}/bin/bash --rcfile \"$out/bashrc\"\"" >> "$out/tmux.conf"
fi
alias tmux="tmux -u -f \"$out/tmux.conf\""

# Configure neovim to use our custom configs:
#  - https://neovim.io/doc/user/starting.html#initialization
#  - https://stackoverflow.com/a/75633317
#  - https://vi.stackexchange.com/questions/37639/viminit-conflicts-for-neovim-and-vim
#
alias nvim="XDG_CONFIG_HOME=\"$out\" NVIM_APPNAME=\"nvim\" nvim"

# Configure starship to use our custom configs
export STARSHIP_CONFIG="$out/starship.toml"
eval "\$(starship init bash)"
EOT
    '';
  };
in
stdenv.mkDerivation {
  name = "dotfiles-shell";
  buildInputs = [
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
  shellHook = ''. ${content}/bashrc'';
}

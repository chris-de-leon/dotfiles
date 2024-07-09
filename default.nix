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
      # Exits early if any command runs into an issue and prints commands as they are executed
      set -ex

      # Copies source files into an output folder
      mkdir -p $out
      cp -rv $src/* $out

      # Tells Nix to give bashrc executable permissions: https://stackoverflow.com/a/61736179
      chmod 777 $out/bashrc
      
      # Configures tmux to use an interactive non-login shell and source our custom bashrc file:
      #  - https://discourse.nixos.org/t/interactive-bash-with-nix-develop-flake/15486
      # - https://unix.stackexchange.com/a/98085
      #  - https://unix.stackexchange.com/a/541352
      #  - https://stackoverflow.com/a/45389462
      #
      if ! grep -q 'set-option -g default-command' "$out/tmux.conf"; then
        # NOTE: this code must not be included in the bashrc file! It writes to a file in /nix/store, so it will cause permission errors:
        # https://nix.dev/manual/nix/2.23/installation/multi-user#multi-user-mode
        echo "set-option -g default-command \"${pkgs.bashInteractive}/bin/bash --rcfile \"$out/bashrc\"\"" >> "$out/tmux.conf"
      fi

      # Dynamically writes more content to our custom bashrc file
      cat <<EOT >> $out/bashrc

# Configures tmux to use our custom configs:
#  - https://unix.stackexchange.com/a/663023
#  - https://askubuntu.com/a/746846
#
alias tmux="tmux -u -f \"$out/tmux.conf\""

# Configures neovim to use our custom configs:
#  - https://vi.stackexchange.com/questions/37639/viminit-conflicts-for-neovim-and-vim
#  - https://neovim.io/doc/user/starting.html#initialization
#  - https://stackoverflow.com/a/75633317
#
alias nvim="XDG_CONFIG_HOME=\"$out\" NVIM_APPNAME=\"nvim\" nvim"

# Configures starship to use our custom configs
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
  shellHook = ''
    export DOTFILES_BASHRC=${content}/bashrc
    export DOTFILES_HOME=${content}
    . ${content}/bashrc
  '';
}

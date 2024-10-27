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
    set -ex
    mkdir -p $out
    cp -v ${bashrc} $out/bashrc
    cp -vr $src/* $out
  '';
}

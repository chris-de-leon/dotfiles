{ pkgs ? import<nixpkgs> {} }:

let
  inherit (pkgs) stdenv;
in

stdenv.mkDerivation {
  name = "configs";

  src = ./.;

  installPhase = ''
    set -e
    mkdir -p $out
    cp -rv $src/* $out
  '';
}

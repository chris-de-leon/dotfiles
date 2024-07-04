{
  # https://github.com/NixOS/nixpkgs/commit/9f4128e00b0ae8ec65918efeba59db998750ead6
  inputs = {
    nixpkgs.url = "https://github.com/NixOS/nixpkgs/archive/9f4128e00b0ae8ec65918efeba59db998750ead6.tar.gz";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem(system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        defaultPackage = pkgs.callPackage ./shell.nix {
          inherit pkgs;
        };

        devShell = pkgs.callPackage ./shell.nix {
          inherit pkgs;
        };
      }
    );
}

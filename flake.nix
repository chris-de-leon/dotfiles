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
        dotfiles = import ./default.nix { inherit pkgs; };
      in {
        defaultPackage = dotfiles;

        devShell = pkgs.mkShell {
          buildInputs = dotfiles.buildInputs;
          shellHook = dotfiles.shellHook;
        };
      }
    );
}

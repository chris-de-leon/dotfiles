# Bumping Tool Versions

## Steps

1. Update the Nix determinate installer version in `install.sh`
1. Update the Ubuntu and Nix versions in the Makefile
1. Update the pinned Nix commit in `flake.nix`
1. Run `make nixupdate`
1. Bump `VERSION`

## Confirming

You can check the tool versions using commands like the following:

```bash
nix shell . --command gh --version
nix shell . --command jq --version
```

## Release

Open a PR, ensure CI passes, and merge.

ARG VERSION=latest
FROM nixos/nix:${VERSION}

ENV NIX_CONFIG="experimental-features = nix-command flakes"

ARG WORKDIR=/
ENV DOTFILES_REPO_PATH=${WORKDIR}
WORKDIR ${WORKDIR}

ARG VERSION=latest
FROM ubuntu:${VERSION}

RUN export DEBIAN_FRONTEND="noninteractive" \
  && apt-get update \
  && apt-get install -y curl git sudo tzdata \
  && rm -rf /var/lib/apt/lists/*

ARG WORKDIR=/
ENV DOTFILES_REPO_PATH=${WORKDIR}
WORKDIR ${WORKDIR}

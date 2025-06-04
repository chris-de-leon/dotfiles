#!/usr/bin/env bash

set -eo pipefail

nix profile install path:/root/.local/share/chezmoi

cd ./chezmoi

exec bash

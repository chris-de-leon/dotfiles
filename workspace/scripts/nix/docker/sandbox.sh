#!/usr/bin/env bash

set -eo pipefail

nix profile add path:/root/.local/share/chezmoi

cd ./chezmoi

exec bash

#!/usr/bin/env bash

set -eo pipefail

# Log Nix version
NIX_VERSION="$(nix --version)"
echo "info: ${NIX_VERSION}"

# Infer path to dev profile
NIX_PROFILE_DIR="$(readlink "${HOME}/.nix-profile")"
DEV_PROFILE_LOC="$(dirname "${NIX_PROFILE_DIR}")/dev"

# Upgrade dev tools
echo "info: upgrading dev tools..."
nix profile upgrade --path "${DEV_PROFILE_LOC}" --all
echo "info: successfully upgraded dev tools"

# Update configurations
echo "info: updating configurations..."
chezmoi update --init --apply
echo "info: successfully updated configurations"

# Print success message
echo "info: upgrade complete"

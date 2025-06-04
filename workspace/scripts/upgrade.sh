#!/usr/bin/env bash

set -eo pipefail

# Log Nix version
NIX_VERSION="$(nix --version)"
echo "info: ${NIX_VERSION}"

# Upgrade dev tools
echo "info: upgrading dev tools..."
nix profile upgrade --path "${HOME}/.nix-profile/profile.devenv" --all
echo "info: successfully upgraded dev tools"

# Update configurations
echo "info: updating configurations..."
chezmoi update --init --apply
echo "info: successfully updated configurations"

# Print success message
echo "info: upgrade complete"

#!/usr/bin/env bash

set -eo pipefail

# For Docker tests
NIX_DAEMON_PTH="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
if ! command -v nix &>/dev/null && [[ -f "${NIX_DAEMON_PTH}" ]]; then
  # shellcheck source=/dev/null
  . "${NIX_DAEMON_PTH}"
fi

# Log Nix version
NIX_VERSION="$(nix --version)"
echo "info: ${NIX_VERSION}"

# Infer path to dev profile
NIX_PROFILE_DIR="$(readlink "${HOME}/.nix-profile")"
DEV_PROFILE_LOC="$(dirname "${NIX_PROFILE_DIR}")/dev"

# Upgrade dev tools
echo "info: upgrading dev tools..."
nix profile upgrade --profile "${DEV_PROFILE_LOC}" --all
echo "info: successfully upgraded dev tools"

# Update configurations
echo "info: updating dotfiles..."
chezmoi update --init --apply
echo "info: successfully updated dotfiles"

# Print success message
echo "info: upgrade complete"
echo "info: you may need to open a new shell for changes to take effect"

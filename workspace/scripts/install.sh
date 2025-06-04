#!/usr/bin/env bash

set -eo pipefail

# Repo details
REPO_OWNER="chris-de-leon"
REPO_NAME="dotfiles"

# Install Nix if it isn't already installed
if ! command -v nix &>/dev/null; then
  echo "info: installing Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
  # shellcheck source=/dev/null
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
  echo "info: Nix is already installed"
fi

# Log Nix version
NIX_VERSION="$(nix --version)"
echo "info: ${NIX_VERSION}"

# Use Nix to install dev tools
NIX_PROFILE_URL="git+https://github.com/${REPO_OWNER}/${REPO_NAME}.git"
NIX_PROFILE_LOC="${HOME}/.nix-profile/profile.devenv"
if nix profile list --no-pretty | grep -q "${NIX_PROFILE_URL}"; then
  echo "info: upgrading dev tools..."
  nix profile upgrade --profile "${NIX_PROFILE_LOC}" --all
  echo "info: successfully upgraded dev tools"
else
  echo "info: installing dev tools..."
  nix profile install --profile "${NIX_PROFILE_LOC}"
  echo "info: successfully installed dev tools"
fi

# Get user credentials
if [[ "${DOTFILES_RECIPE:-}" == "secrets" ]]; then
  if [[ -z "${LASTPASS_USERNAME:-}" ]]; then
    read -rp "info: please enter your LastPass username: " LASTPASS_USERNAME </dev/tty && echo ""
    lpass login --trust "${LASTPASS_USERNAME}"
  fi
else
  if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    read -rps "info: please enter your GitHub PAT: " GITHUB_TOKEN </dev/tty && echo ""
    export GITHUB_TOKEN="${GITHUB_TOKEN}"
  fi
fi

# Apply configurations
echo "info: applying configurations..."
chezmoi init --apply "https://github.com/${REPO_OWNER}/${REPO_NAME}.git"
echo "info: successfully applied configurations"

# Print success message
echo "info: installation complete"

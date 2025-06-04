#!/usr/bin/env bash

set -eo pipefail

# Helper Vars
NIX_DAEMON="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
REPO_OWNER="chris-de-leon"
REPO_NAME="dotfiles"

# If Nix doesn't exist, then try to source the daemon first
if ! command -v nix &>/dev/null && [[ -f "${NIX_DAEMON}" ]]; then
  # shellcheck source=/dev/null
  . "${NIX_DAEMON}"
fi

# If Nix still isn't available, then install it
if ! command -v nix &>/dev/null; then
  echo "info: installing Nix..."
  curl --proto '=https' --tlsv1.2 -sSf -L 'https://install.determinate.systems/nix/tag/v3.6.2' | sh -s -- install --no-confirm
  # shellcheck source=/dev/null
  . "${NIX_DAEMON}"
else
  echo "info: Nix is already installed"
fi

# Log Nix version
NIX_VERSION="$(nix --version)"
echo "info: ${NIX_VERSION}"

# Use Nix to install dev tools
NIX_PROFILE_URL="git+https://github.com/${REPO_OWNER}/${REPO_NAME}.git"
NIX_PROFILE_LOC="${HOME}/.nix-profile/profile.devenv"
NIX_PROFILE_DIR="$(readlink "${HOME}/.nix-profile")"
mkdir -p "${NIX_PROFILE_DIR}"
if nix profile list --no-pretty | grep -q "${NIX_PROFILE_URL}"; then
  echo "info: upgrading dev tools..."
  nix profile upgrade --profile "${NIX_PROFILE_LOC}" --all
  echo "info: successfully upgraded dev tools"
else
  echo "info: installing dev tools..."
  nix profile install --profile "${NIX_PROFILE_LOC}" "${NIX_PROFILE_URL}"
  echo "info: successfully installed dev tools"
fi

# Get user credentials
if [[ "${DOTFILES_RECIPE:-}" == "secrets" ]]; then
  if [[ -z "${LASTPASS_USERNAME:-}" ]]; then
    read -rp "info: please enter your LastPass username: " LASTPASS_USERNAME && echo ""
    lpass login --trust "${LASTPASS_USERNAME}"
  fi
else
  if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    read -rps "info: please enter your GitHub PAT: " GITHUB_TOKEN && echo ""
    export GITHUB_TOKEN="${GITHUB_TOKEN}"
  fi
fi

# Apply configurations
echo "info: applying configurations..."
chezmoi init --apply "https://github.com/${REPO_OWNER}/${REPO_NAME}.git"
echo "info: successfully applied configurations"

# Print success message
echo "info: installation complete"

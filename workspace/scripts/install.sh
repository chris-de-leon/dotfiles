#!/usr/bin/env bash

set -eo pipefail

# Helper Vars
NIX_DAEMON_PTH="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
NIX_INSTLR_URL="https://install.determinate.systems/nix/tag/v3.6.2"
OS_KERNEL_NAME="$(uname -s)"

# Dotfile Configurations
DOTFILES_GIT_URL="https://github.com/chris-de-leon/dotfiles.git"
DOTFILES_NIX_URL="${DOTFILES_NIX_URL:-git+${DOTFILES_GIT_URL}}"
DOTFILES_AUTH="${DOTFILES_AUTH:-}"

# Check if the script is being invoked inside a Docker container
IS_DOCKER_LINUX_ENV="false"
if [[ -f /.dockerenv ]] && [[ "${OS_KERNEL_NAME}" == "Linux" ]]; then
  echo "info: detected Docker Linux environment"
  IS_DOCKER_LINUX_ENV="true"
fi

# Install Nix if it isn't already installed
if ! command -v nix &>/dev/null && [[ ! -f "${NIX_DAEMON_PTH}" ]]; then
  echo "info: installing Nix..."
  if [[ "${IS_DOCKER_LINUX_ENV}" == 'true' ]]; then
    curl --proto '=https' --tlsv1.2 -sSf -L "${NIX_INSTLR_URL}" | sh -s -- install linux --extra-conf "sandbox = false" --init none --no-confirm
  else
    curl --proto '=https' --tlsv1.2 -sSf -L "${NIX_INSTLR_URL}" | sh -s -- install --no-confirm
  fi
fi

# shellcheck source=/dev/null # Start the Nix daemon
. "${NIX_DAEMON_PTH}"

# Log Nix version
NIX_VERSION="$(nix --version)"
echo "info: ${NIX_VERSION}"

# This creates a symlink for ~/.nix-profile if it does not already exist.
# This is important because we need to read this link to get the path to
# the directory that our custom dev profile should be created in.
echo "info: ensuring all packages in default profile are up to date"
nix profile upgrade --all
echo "info: all packages in default profile have been updated"

# Use Nix to install dev tools
NIX_PROFILE_DIR="$(readlink "${HOME}/.nix-profile")"
DEV_PROFILE_LOC="$(dirname "${NIX_PROFILE_DIR}")/dev"
if nix profile list --no-pretty | grep -q "${DOTFILES_NIX_URL}"; then
  echo "info: upgrading dev tools..."
  nix profile upgrade --profile "${DEV_PROFILE_LOC}" --all
  echo "info: successfully upgraded dev tools"
else
  echo "info: installing dev tools..."
  nix profile install --profile "${DEV_PROFILE_LOC}" "${DOTFILES_NIX_URL}"
  echo "info: successfully installed dev tools"
fi

# Add dev tools to PATH so that we can invoke chezmoi (and others) later in this script if needed
export PATH="${DEV_PROFILE_LOC}/bin:${PATH}"

# A completely fresh VM may not have these directories created by default, so we'll need to create
# them on our side if they don't already exist. If we don't do this then apps such as LastPass will
# throw an error (LastPass itself doesn't automatically create the directories it uses).
mkdir -p "${HOME}/.local/share"
mkdir -p "${HOME}/.config"

# NOTE: if no password manager is provided then all secrets (e.g. DockerHub, Terraform Cloud,
# etc.) will be obtained from env vars. If they do not exist, then they will be excluded from
# the templates. We still require the user's GitHub PAT to setup GitHub for development.
#
# NOTE: if a password manager is provided, then we'll assume that it already contains all the
# necessary secrets for the chezmoi templates for simplicty. Additional password managers can
# be added in the future with the way the code below is structured. If a new password manager
# is added, then the templates will need to be updated accordingly to support it.
#
# Handle authentication
if [[ -z "${DOTFILES_AUTH}" ]]; then
  echo "info: dotfile secrets will be sourced from environment variables"
  if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    echo "error: environment variable 'GITHUB_TOKEN' was not provided" && exit 1
  else
    export GITHUB_TOKEN="${GITHUB_TOKEN}"
  fi
elif [[ "${DOTFILES_AUTH}" == 'lastpass' ]]; then
  echo "info: dotfile secrets will be sourced from LastPass"
  if [[ -z "${LASTPASS_USERNAME:-}" ]]; then
    echo "error: environment variable 'LASTPASS_USERNAME' was not provided" && exit 1
  else
    lpass login --trust "${LASTPASS_USERNAME}"
  fi
else
  echo "error: '${DOTFILES_AUTH}' is an invalid authentication method " && exit 1
fi

# If we're inside a Docker container, then exit early
if [[ "${IS_DOCKER_LINUX_ENV}" == 'true' ]]; then
  exit 0
fi

# Run chezmoi
echo "info: applying configurations..."
chezmoi init "${DOTFILES_GIT_URL}" --apply
echo "info: successfully applied configurations"

# Print success message
echo "info: installation complete!"
echo "info: to get started, please open a new shell"

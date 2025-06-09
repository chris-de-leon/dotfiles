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
  nix profile upgrade --profile "${DEV_PROFILE_LOC}" --all --override-input "nixpkgs" "github:NixOS/nixpkgs/nixos-25.05"
  echo "info: successfully upgraded dev tools"
else
  echo "info: installing dev tools..."
  nix profile install --profile "${DEV_PROFILE_LOC}" "${DOTFILES_NIX_URL}" --override-input "nixpkgs" "github:NixOS/nixpkgs/nixos-25.05"
  echo "info: successfully installed dev tools"
fi

# Add the dev profile to PATH so that we can invoke tools
# like chezmoi and others later in this script if needed
export PATH="${DEV_PROFILE_LOC}/bin:${PATH}"

# NOTE: for simplicty, only one password manager will be supported at a time
# in the templates. At the moment, Bitwarden is used since it's open source,
# highly secure, and has good tooling support. It also allows us to keep the
# tooling stack free of the use of NIXPKGS_ALLOW_UNFREE=1 and `--impure` for
# Nix shells. If the password manager is defined, then it is assumed that it
# already contains all the necessary secrets for the chezmoi templates. If a
# password manager is not provided, then all secrets for `~/.bashrc` will be
# sourced from env vars. If some environment variables don't exist, then the
# templates will exclude them. The only exception is the user's GITHUB_TOKEN
# since it is required to configure GitHub for development.
#
# Helper variable to check if a valid auth method was provided
IS_AUTHENTICATED='false'

# Bitwarden auth
if [[ "${DOTFILES_AUTH}" == 'bitwarden' ]]; then
  echo "info: dotfile secrets will be sourced from 1password"
  if [[ -z "${BW_CLIENTID:-}" ]] && [[ -z "${BW_CLIENTSECRET}" ]]; then
    echo "error: environment variables 'BW_CLIENTID' and 'BW_CLIENTSECRET' must be provided"
    exit 1
  else
    export BW_SESSION=""
    bw login --apikey
    BW_SESSION="$(bw unlock --raw)"
  fi
  IS_AUTHENTICATED='true'
fi

# Environment variable auth
if [[ -z "${DOTFILES_AUTH}" ]]; then
  echo "info: dotfile secrets will be sourced from environment variables"
  if [[ -z "${GITHUB_TOKEN:-}" ]]; then
    echo "error: environment variable 'GITHUB_TOKEN' must be provided"
    exit 1
  fi
  IS_AUTHENTICATED='true'
fi

# If an invalid auth method was provided, then exit with an error
if [[ "${IS_AUTHENTICATED}" == 'false' ]]; then
  echo "error: '${DOTFILES_AUTH}' is an invalid authentication method "
  exit 1
fi

# If this script is running inside a Docker container, exit early with a success status
if [[ "${IS_DOCKER_LINUX_ENV}" == 'true' ]]; then
  echo "info: script completed successfully - skipping chezmoi setup for now"
  exit 0
fi

# Run chezmoi
echo "info: applying configurations..."
chezmoi init "${DOTFILES_GIT_URL}" --apply
echo "info: successfully applied configurations"

# Print success message
echo "info: installation complete!"
echo "info: to get started, please open a new shell"

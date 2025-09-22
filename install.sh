#!/usr/bin/env bash

set -eo pipefail

OS_KERNEL_NAME="$(uname -s | tr '[:upper:]' '[:lower:]')"
INSTALLER_VERS="v3.11.2"

info() { echo "info: ${1}"; }

main() {
  # Install Determinate Nix
  local nix_install_url="https://install.determinate.systems/nix/tag/${INSTALLER_VERS}"
  local nix_daemon_path="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  if ! command -v nix &>/dev/null && [[ ! -f "${nix_daemon_path}" ]]; then
    info "installing Determinate Nix..."
    if [[ -f /.dockerenv ]] && [[ "${OS_KERNEL_NAME}" == 'linux' ]]; then
      curl --proto '=https' --tlsv1.2 -sSf -L "${nix_install_url}" | sh -s -- install linux --no-confirm --determinate --extra-conf "sandbox = false" --init none
    else
      curl --proto '=https' --tlsv1.2 -sSf -L "${nix_install_url}" | sh -s -- install --no-confirm --determinate
    fi
  fi

  # shellcheck source=/dev/null # Start the Nix daemon
  . "${nix_daemon_path}"

  # Ensure that nix command is available
  local version
  version="$(nix --version)"
  info "${version}"

  # NOTE: `nix profile upgrade --all` creates a symlink at "${HOME}/.nix-profile" if one
  # does not already exist. This is important because later we'll need to read from this
  # symlink to get the path to the directory where our custom dev profile should live in
  info "ensuring all packages in default profile are up to date"
  nix profile upgrade --all
  info "all packages in default profile are up to date"

  # Double check that the symlink exists
  local nix_profile_lnk="${HOME}/.nix-profile"
  if [[ ! -L "${nix_profile_lnk}" ]]; then
    fail "no symlink exists at ${nix_profile_lnk}"
  fi

  # Get the path to the current working directory
  local workdir
  workdir="$(pwd)"

  # Run the setup script
  info "running setup script..."
  if [[ -f /.dockerenv ]]; then
    nix run "path:${workdir}#setup" -- "${@}"
  else
    nix run "github:chris-de-leon/dotfiles#setup" -- "${@}"
  fi
}

main "${@}"

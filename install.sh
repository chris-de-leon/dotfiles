#!/usr/bin/env bash

set -eo pipefail

OS_KERNEL_NAME="$(uname -s | tr '[:upper:]' '[:lower:]')"
PATH_TO_BASHRC="${HOME}/.bashrc"
INSTALLER_VERS="v3.15.2"

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
  # symlink to perform some more setup steps for the dev environment.
  info "ensuring all packages in default profile are up to date"
  nix profile upgrade --all
  info "all packages in default profile are up to date"

  # Double check that the symlink exists
  local nix_profile_lnk="${HOME}/.nix-profile"
  if [[ ! -L "${nix_profile_lnk}" ]]; then
    fail "no symlink exists at ${nix_profile_lnk}"
  fi

  # shellcheck disable=SC2016 # Single quotes are intentional - expression should not be expanded
  local devkit_ini='if command -v devkit &>/dev/null; then eval "$(devkit init)"; fi'
  if ! grep -Fxq "${devkit_ini}" "${PATH_TO_BASHRC}"; then
    printf '\n%s\n' "${devkit_ini}" >>"${PATH_TO_BASHRC}"
  fi

  # If we're in a docker env, then install from a local path otherwise use GitHub
  local devkit_loc='github:chris-de-leon/dotfiles'
  if [[ -f /.dockerenv ]]; then
    devkit_loc="path:$(pwd)"
  fi

  # Setup dotfiles
  nix shell "${devkit_loc}" --command devkit migrate
}

main "${@}"

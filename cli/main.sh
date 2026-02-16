#!/usr/bin/env bash

set -eo pipefail

export DEVKIT_HOME="${HOME}/.devkit"
export DEVKIT_REPO="${DEVKIT_HOME}/dotfiles"

fail() { echo "error: ${1}" && exit 1; }
warn() { echo "warn: ${1}"; }

install_tailscale() {
  if ! command -v tailscale &>/dev/null; then
    curl -fsSL 'https://tailscale.com/install.sh' | sh
  fi
}

install_docker() {
  local os=""
  local id=""

  os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  if [[ "${os}" != "linux" ]]; then
    fail "unsupported OS '${os}' - please install docker manually"
  fi

  if ! command -v docker &>/dev/null; then
    # Adds the current user to the docker group so that
    # there is no need to invoke `sudo` before `docker`
    curl -fsSL 'https://get.docker.com' | sh
    sudo usermod -aG docker "${USER}"
    warn "docker group added; log out and back in for it to take effect"
  fi

  if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    id="${ID:-unknown}"
  fi

  if [[ "${id}" == "ubuntu" || "${id}" == "debian" ]]; then
    sudo apt-get --fix-broken install -y
    sudo apt-get update
    sudo apt-get upgrade -y

    if [[ "${id}" == "ubuntu" ]]; then
      sudo apt-get install -y qemu-user-static
    fi

    sudo apt-get autoremove -y
  fi
}

install() {
  while [[ $# -gt 0 ]]; do
    local flag="${1:-}"
    case "${flag}" in
    --tailscale)
      install_tailscale
      shift
      ;;
    --docker)
      install_docker
      shift
      ;;
    *)
      echo "Unknown flag: ${flag}" >&2
      exit 1
      ;;
    esac
  done
}

migrate() {
  # Ensure that the repo exists
  if [[ ! -d "${DEVKIT_REPO}" ]]; then
    git -C "${DEVKIT_HOME}" clone 'https://github.com/chris-de-leon/dotfiles.git'
  fi

  # Get the version to migrate to
  local vers && vers="${1:-master}"

  # Get the path to the directory where all dotfile subdirectories live
  local conf && conf="${DEVKIT_REPO}/cfg"

  # Get a space separated list of all the dotfile subdirectories
  local dirs && dirs="$( (cd "${conf}" && ls -d -- *))"

  # Clean up any symlinks on the current version
  # shellcheck disable=SC2086 # this should work as long as folder names have no spaces
  stow -D -t "${HOME}" -d "${conf}" ${dirs}

  # Checkout the desired version (if on master, then pull the latest files)
  git -C "${DEVKIT_REPO}" checkout "${vers}"
  if [[ "${vers}" == 'master' ]]; then
    git -C "${DEVKIT_REPO}" pull -X ours
  fi

  # Now re-add the symlinks for the version we migrated to
  # shellcheck disable=SC2086 # this should work as long as folder names have no spaces
  stow -R -t "${HOME}" -d "${conf}" ${dirs}

  # Upgrade the dotfiles package if it exists (otherwise add it)
  if nix profile list --no-pretty | grep -Fq "${DEVKIT_REPO}"; then
    nix profile upgrade dotfiles
  else
    nix profile add "path:${DEVKIT_REPO}"
  fi
}

gitauth() {
  # NOTE: we assume that `git` is already installed on the
  # machine and that the devenv will provide `gh` and `jq`
  command -v gh >/dev/null || fail "gh is required"
  command -v jq >/dev/null || fail "jq is required"

  if [[ -z "${GH_TOKEN}" ]] && [[ -z "${GITHUB_TOKEN}" ]]; then
    gh auth login
  fi

  local gh_user_accnt_info="" && gh_user_accnt_info="$(gh api user)"
  local gh_user_accnt_name="" && gh_user_accnt_name="$(echo "${gh_user_accnt_info}" | jq -erc '.login')"
  local gh_user_identifier="" && gh_user_identifier="$(echo "${gh_user_accnt_info}" | jq -erc '.id')"

  git config --global user.email "${gh_user_identifier}+${gh_user_accnt_name}@users.noreply.github.com"
  git config --global user.name "${gh_user_accnt_name}"
  git config --global init.defaultBranch "master"
  git config --global core.editor "vim"
}

profile() {
  local profile_link="${HOME}/.nix-profile"
  if [[ ! -L "${profile_link}" ]]; then
    fail "no symlink exists at ${profile_link}"
  else
    readlink "${profile_link}"
  fi
}

version() {
  echo "${DEVKIT_VRSN:-unknown}"
}

home() {
  echo "${DEVKIT_HOME}"
}

init() {
  local fpath && fpath="$(profile)/${DEVKIT_INIT:-etc/profile.d/init}"
  cat "${fpath}"
}

main() {
  local op="${1:-}"
  case "${op}" in
  install) install "${@:2}" ;;
  migrate) migrate "${@:2}" ;;
  gitauth) gitauth "${@:2}" ;;
  profile) profile "${@:2}" ;;
  version) version "${@:2}" ;;
  home) home "${@:2}" ;;
  init) init "${@:2}" ;;
  *)
    echo "Invalid option: ${op}"
    echo "Usage: ${0} {install|migrate|gitauth|profile|version|home|init}"
    exit 1
    ;;
  esac
}

main "${@}"

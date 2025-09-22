#!/usr/bin/env bash

set -eo pipefail

OS_KERNEL_NAME="$(uname -s | tr '[:upper:]' '[:lower:]')"

fail() { echo "error: ${1}" && exit 1; }
warn() { echo "warn: ${1}"; }

setup_tailscale() {
  if ! command -v tailscale &>/dev/null; then
    curl -fsSL 'https://tailscale.com/install.sh' | sh
  fi
}

setup_docker() {
  local id=""

  if [[ "${OS_KERNEL_NAME}" != "linux" ]]; then
    fail "unsupported OS_KERNEL_NAME '${OS_KERNEL_NAME}' - please install docker manually"
  fi

  if ! command -v docker &>/dev/null; then
    # Adds the current user to the docker group so that
    # there is no need to invoke `sudo` before `docker`
    curl -fsSL 'https://get.docker.com' | sh
    sudo usermod -aG docker "${USER}"
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

setup_git() {
  local gh_user_accnt_info=""
  local gh_user_accnt_name=""
  local gh_user_identifier=""

  if [[ -z "${GH_TOKEN}" ]] && [[ -z "${GITHUB_TOKEN}" ]]; then
    gh auth login
  fi

  gh_user_accnt_info="$(gh api user)"
  gh_user_accnt_name="$(echo "${gh_user_accnt_info}" | jq -erc '.login')"
  gh_user_identifier="$(echo "${gh_user_accnt_info}" | jq -erc '.id')"

  git config --global user.email "${gh_user_identifier}+${gh_user_accnt_name}@users.noreply.github.com"
  git config --global user.name "${gh_user_accnt_name}"
  git config --global init.defaultBranch "master"
  git config --global credential.helper "store"
  git config --global safe.directory "*"
  git config --global core.editor "vim"
}

main() {
  devkit initialize
  while [[ $# -gt 0 ]]; do
    case "${1}" in
    --tailscale)
      setup_tailscale
      ;;
    --docker)
      setup_docker
      ;;
    --git)
      setup_git
      ;;
    *)
      warn "unknown option: ${1}"
      ;;
    esac
    shift
  done
}

main "${@}"

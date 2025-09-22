#!/usr/bin/env bash

set -eo pipefail

export DOTFILES_REPO="https://github.com/chris-de-leon/dotfiles.git"
export DOTFILES_HOME="${HOME}/${DOTFILES_HOME:-.local/share/chris-de-leon/dotfiles}"
export DOTFILES_INIT="${DOTFILES_INIT:-/etc/profile.d/init}"
export DOTFILES_VRSN="${DOTFILES_VRSN:-unknown}"
export DOTFILES_CNFG="${DOTFILES_HOME}/configs"
export NIX_PROF_LINK="${HOME}/.nix-profile"
export BASHRC_ABSPTH="${HOME}/.bashrc"
export DOTFILES_MAIN="master"

fail() { echo "error: ${1}" && exit 1; }

initialize() {
  # Ensure that the repo exists and the dev profile is up to date
  if [[ -d "${DOTFILES_HOME}" ]]; then refresh; else clone; fi

  # Get the path to the file that should be sourced to activate the dev environment
  local dev_profile_ini=""
  dev_profile_ini="$(profile)/${DOTFILES_INIT}"

  # Build the command that should be added to ~/.bashrc
  local dev_profile_src=""
  dev_profile_src="if [[ -f \"${dev_profile_ini}\" ]]; then . \"${dev_profile_ini}\"; fi"

  # Ensure that bashrc activates the dev profile on startup
  if ! grep -Fxq "${dev_profile_src}" "${BASHRC_ABSPTH}"; then
    echo "${dev_profile_src}" >>"${BASHRC_ABSPTH}"
  fi

  # Symlink dotfiles
  restow
}

rollback() {
  local ref="${1:-}"
  if [[ -z "${ref}" ]]; then
    fail "argument 1 (git ref) is required"
  fi

  unstow
  git -C "${DOTFILES_HOME}" checkout "${ref}"
  restow
  refresh
}

migrate() {
  unstow
  git -C "${DOTFILES_HOME}" checkout "${DOTFILES_MAIN}"
  git -C "${DOTFILES_HOME}" pull -X ours
  restow
  refresh
}

version() {
  echo "${DOTFILES_VRSN}"
}

profile() {
  if [[ ! -L "${NIX_PROF_LINK}" ]]; then
    fail "no symlink exists at ${NIX_PROF_LINK}"
  fi

  local nix_profile_dir=""
  nix_profile_dir="$(readlink "${NIX_PROF_LINK}")"

  local dev_profile_dir=""
  dev_profile_dir="$(dirname "${nix_profile_dir}")/dev"

  echo "${dev_profile_dir}"
}

refresh() {
  local profile_path=""
  profile_path="$(profile)"

  if nix profile list --profile "${profile_path}" --no-pretty | grep -Fq "${DOTFILES_HOME}"; then
    nix profile upgrade --profile "${profile_path}" --all
  else
    nix profile add --profile "${profile_path}" "path:${DOTFILES_HOME}"
  fi
}

cfgdirs() {
  for item in "${DOTFILES_CNFG}"/*/; do [[ -d "${item}" ]] && printf '%s ' "$(basename "${item}")"; done
}

cfgpath() {
  echo "${DOTFILES_CNFG}"
}

unstow() {
  local dotfiles_dirs=""
  dotfiles_dirs="$(cfgdirs)"

  # shellcheck disable=SC2086 # this should work as long as folder names have no spaces
  stow -D -t "${HOME}" -d "${DOTFILES_CNFG}" ${dotfiles_dirs}
}

restow() {
  local dotfiles_dirs=""
  dotfiles_dirs="$(cfgdirs)"

  # shellcheck disable=SC2086 # this should work as long as folder names have no spaces
  stow -R -t "${HOME}" -d "${DOTFILES_CNFG}" ${dotfiles_dirs}
}

clone() {
  local dir=""
  dir="$(dirname "${DOTFILES_HOME}")"
  mkdir -p "${dir}"
  git clone "${DOTFILES_REPO}" "${DOTFILES_HOME}"
  refresh
}

hist() {
  local profile_path=""
  profile_path="$(profile)"
  nix profile history --profile "${profile_path}"
}

list() {
  local profile_path=""
  profile_path="$(profile)"
  nix profile list --profile "${profile_path}"
}

home() {
  echo "${DOTFILES_HOME}"
}

main() {
  local op="${1:-}"
  case "${op}" in
  initialize)
    initialize "${@:2}"
    ;;
  rollback)
    rollback "${@:2}"
    ;;
  migrate)
    migrate "${@:2}"
    ;;
  version)
    version "${@:2}"
    ;;
  profile)
    profile "${@:2}"
    ;;
  refresh)
    refresh "${@:2}"
    ;;
  cfgdirs)
    cfgdirs "${@:2}"
    ;;
  cfgpath)
    cfgpath "${@:2}"
    ;;
  unstow)
    unstow "${@:2}"
    ;;
  restow)
    restow "${@:2}"
    ;;
  clone)
    clone "${@:2}"
    ;;
  hist)
    hist "${@:2}"
    ;;
  list)
    list "${@:2}"
    ;;
  home)
    home "${@:2}"
    ;;
  *)
    echo "Invalid option: ${op}"
    echo "Usage: ${0} {initialize|rollback|migrate|version|profile|refresh|cfgdirs|cfgpath|unstow|restow|clone|hist|list|home}"
    exit 1
    ;;
  esac
}

main "${@}"

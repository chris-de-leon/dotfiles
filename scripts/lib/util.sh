#!/usr/bin/env bash

util_setup_container() {
  # NOTE: `docker cp` does not respect `.dockerignore`, which means unwanted folders like
  # `.git` will always be copied into the container. This is problematic for our use case
  # because it results in Nix throwing an error along the lines of "repository path '...'
  # is not owned by current user". To avoid this issue, removing the `.git` folder should
  # do the trick. For testing purposes, we shouldn't be doing any outbound Git operations
  # anyways so this approach ensures that Nix comlies with this.
  if [[ -z "${DOTFILES_REPO_PATH}" ]]; then
    echo "error: environment variable 'DOTFILES_REPO_PATH' must be provided" && exit 1
  else
    rm -rf "${DOTFILES_REPO_PATH}/.git"
  fi

  if command -v apt-get &>/dev/null; then
    apt-get update
    apt-get upgrade -y
    apt-get install -y curl git sudo tzdata
  fi
}

util_setup_default_profile() {
  # for debugging purposes, use the default profile for simplicity instead of creating a separate one
  if [[ -z "${DOTFILES_REPO_PATH}" ]]; then
    echo "error: environment variable 'DOTFILES_REPO_PATH' must be provided" && exit 1
  else
    nix profile add "path:${DOTFILES_REPO_PATH}"
  fi
}

util_run_install_script() {
  if [[ -z "${DOTFILES_INSTALLER}" ]]; then
    echo "error: environment variable 'DOTFILES_INSTALLER' must be provided" && exit 1
  else
    echo "info: running script at '${DOTFILES_INSTALLER}'... "
    bash "${DOTFILES_INSTALLER}" "${@}"
  fi
}

#!/usr/bin/env bash

util_use_sandbox_configs() {
  # Safety check - only perform git commands in a sandboxed container environment
  if [[ ! -f /.dockerenv ]]; then
    echo "error: util_use_sandbox_configs can only be called in a docker container"
    exit 1
  fi

  # Ensure that the path to the repo root directory is provided as input
  local repo_path="${1:-}"
  if [[ -z "${repo_path}" ]]; then
    echo "error: argument 1 (path to repo) is required"
    exit 1
  fi

  # Ignore permission errors that occur due to copying the repo into the container
  git config --global --add safe.directory "${repo_path}"

  # Make sure all files are staged so that Nix can find them
  git -C "${repo_path}" add -A
}

util_run_install_script() {
  local installer="${1:-.}/install.sh"
  echo "info: running script at '${installer}'... "
  bash -x "${installer}" "${@}"
}

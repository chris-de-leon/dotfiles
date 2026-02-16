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

  # Setup Git config with sandbox settings
  git config --global --add safe.directory "${repo_path}"
  git config --global init.defaultBranch 'master'
  git config --global user.email 'sandbox.user@mail.com'
  git config --global user.name 'sandbox.user'

  # Create a bare repo inside the container
  local sandbox_origin='/tmp/sandbox-origin.git'
  if [[ ! -d "${sandbox_origin}" ]]; then
    git init --bare "${sandbox_origin}"
  fi

  # Make `git pull` / `git push` operate on the bare repo (not the real one)
  git -C "${repo_path}" remote remove origin 2>/dev/null || true
  git -C "${repo_path}" remote add origin "${sandbox_origin}"

  # Flatten the current branch state into master and snapshot uncommitted changes
  git checkout -B master
  git add -A
  git diff --cached --quiet || git commit -m "sandbox snapshot"
  git push -u origin master
}

util_run_install_script() {
  local installer="${1:-.}/install.sh"
  echo "info: running script at '${installer}'... "
  bash -x "${installer}" "${@}"
}

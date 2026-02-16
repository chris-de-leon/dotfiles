#!/usr/bin/env bash

set -eo pipefail

if [[ -z "${DOTFILES_REPO_PATH}" ]]; then
  echo "error: environment variable 'DOTFILES_REPO_PATH' must be provided" && exit 1
fi

# shellcheck source=/dev/null
. "${DOTFILES_REPO_PATH}/dev/lib/utils.sh"
util_use_sandbox_configs "${DOTFILES_REPO_PATH}"

# This creates a sandbox with the devenv tools
# installed and fully configured with dotfiles
# and bashrc.
util_run_install_script "${DOTFILES_REPO_PATH}"

exec bash

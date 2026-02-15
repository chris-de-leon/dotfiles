#!/usr/bin/env bash

set -eo pipefail

if [[ -z "${DOTFILES_REPO_PATH}" ]]; then
  echo "error: environment variable 'DOTFILES_REPO_PATH' must be provided" && exit 1
fi

# shellcheck source=/dev/null
. "${DOTFILES_REPO_PATH}/dev/lib/utils.sh"
util_use_sandbox_configs "${DOTFILES_REPO_PATH}"

# This creates a sandbox with only the devenv tools installed.
# No dotfiles will be added and bashrc won't be configured, so
# all tools will use default configurations.
nix profile add "path:${DOTFILES_REPO_PATH}"

exec bash

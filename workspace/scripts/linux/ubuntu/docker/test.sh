#!/usr/bin/env bash

set -eo pipefail

# Import test utils
SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 && pwd -P)"

# shellcheck source=/dev/null
. "${SCRIPT_DIR}/util.sh"

# Prevent certain tools from being installed inside the container
create_stub "tailscale"
create_stub "docker"

# Setup the container
setup_container

# Begin tests
echo ""
echo "info: ================"
echo "info: Running tests..."
echo "info: ================"
echo ""

# Dotfiles should not exist yet
assert_file_not_exists "${HOME}/.config/tmux/tmux.conf"
assert_file_not_exists "${HOME}/.config/starship.toml"
assert_file_not_exists "${HOME}/.git-credentials"
assert_file_not_exists "${HOME}/.bashrc-secrets"
assert_file_not_exists "${HOME}/.bashrc-tools"
assert_dir_not_exists "${HOME}/.config/nvim"
assert_file_not_exists "${HOME}/.gitconfig"

# Create the dotfiles
echo "info: applying configurations..."
cd ./chezmoi && chezmoi init --apply
echo "info: configurations have been applied successfully"

# Dotfiles should exist
assert_file_exists "${HOME}/.config/tmux/tmux.conf"
assert_file_exists "${HOME}/.config/starship.toml"
assert_file_exists "${HOME}/.git-credentials"
assert_file_exists "${HOME}/.bashrc-secrets"
assert_file_exists "${HOME}/.bashrc-tools"
assert_dir_exists "${HOME}/.config/nvim"
assert_file_exists "${HOME}/.gitconfig"

# No other unnecessary files should have been added
#
# NOTE: files beginning with `.` are ignored by default
# so we don't need to worry about .github or .gitignore
# see: https://www.chezmoi.io/reference/special-files.
# However, we'll add checks for these just to be safe.
assert_file_not_exists "${HOME}/.gitignore"
assert_file_not_exists "${HOME}/flake.lock"
assert_file_not_exists "${HOME}/flake.nix"
assert_file_not_exists "${HOME}/README.md"
assert_file_not_exists "${HOME}/workspace"
assert_file_not_exists "${HOME}/Makefile"
assert_file_not_exists "${HOME}/VERSION"
assert_dir_not_exists "${HOME}/.github"

# Check file content
assert_line_exists "${HOME}/.bashrc-secrets" "export DOCKERHUB_USERNAME=\"dummy-username\""
assert_line_exists "${HOME}/.bashrc-secrets" "export DOCKERHUB_PASSWORD=\"dummy-password\""
assert_line_exists "${HOME}/.bashrc-secrets" "export TF_TOKEN=\"dummy-token\""
assert_line_exists "${HOME}/.bashrc-tools" "  eval \"\$(starship init bash)\""
assert_line_exists "${HOME}/.bashrc" "  . \"\${HOME}/.bashrc-secrets\""
assert_line_exists "${HOME}/.bashrc" "  . \"\${HOME}/.bashrc-tools\""

# End tests
echo "info: all tests PASSED"

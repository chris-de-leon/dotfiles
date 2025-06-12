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

# Nix profile should be setup properly
DEV_PROFILE="$(get_nix_profiles_dir)/dev"
assert_link_exists "${DEV_PROFILE}"
assert_dir_exists "${DEV_PROFILE}/bin"

# Dotfiles should not exist yet
assert_file_not_exists "${HOME}/.config/tmux/tmux.conf"
assert_file_not_exists "${HOME}/.config/starship.toml"
assert_file_not_exists "${HOME}/.git-credentials"
assert_file_not_exists "${HOME}/.bashrc-dotfiles"
assert_file_not_exists "${HOME}/.bashrc-secrets"
assert_file_not_exists "${HOME}/.bashrc-tools"
assert_dir_not_exists "${HOME}/.config/nvim"
assert_file_not_exists "${HOME}/.gitconfig"

# Create the dotfiles
echo "info: applying configurations with chezmoi..."
cd ./chezmoi && chezmoi init --apply
echo "info: configurations have been applied successfully"

# Get the path to the chezmoi directory
CHEZMOI_DIR="$(pwd)"

# Dotfiles should exist
assert_file_exists "${HOME}/.config/tmux/tmux.conf"
assert_file_exists "${HOME}/.config/starship.toml"
assert_file_exists "${HOME}/.git-credentials"
assert_file_exists "${HOME}/.bashrc-dotfiles"
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
assert_dir_not_exists "${HOME}/.git"

# Check file content
assert_line_exists "${HOME}/.bashrc" "if [ -f \"\${HOME}/.bashrc-dotfiles\" ]; then . \"\${HOME}/.bashrc-dotfiles\"; fi"
assert_line_exists "${HOME}/.bashrc-dotfiles" "  . \"\${HOME}/.bashrc-secrets\""
assert_line_exists "${HOME}/.bashrc-dotfiles" "  . \"\${HOME}/.bashrc-tools\""
assert_line_exists "${HOME}/.bashrc-secrets" "export DOCKERHUB_USERNAME=\"dummy-username\""
assert_line_exists "${HOME}/.bashrc-secrets" "export DOCKERHUB_PASSWORD=\"dummy-password\""
assert_line_exists "${HOME}/.bashrc-secrets" "export TF_TOKEN=\"dummy-token\""
assert_line_exists "${HOME}/.bashrc-tools" "    export PATH=\"\${DEV_PROFILE_BIN}:\${PATH}\""
assert_line_exists "${HOME}/.bashrc-tools" "  STARSHIP_INIT=\"\$(starship init bash)\""
assert_line_exists "${HOME}/.bashrc-tools" "  eval \"\${STARSHIP_INIT}\""

# Check generated shell files
run_shellcheck "${HOME}/.bashrc-dotfiles"
run_shellcheck "${HOME}/.bashrc-secrets"
run_shellcheck "${HOME}/.bashrc-tools"

# Check upgrade script (basic sanity check)
echo "info: starting upgrade test"
LINE_COUNT_START="$(wc -l <"${HOME}/.bashrc")"
BASHRC_CAT_START="$(cat "${HOME}/.bashrc")"
DOTFILES_NIX_URL="path:${CHEZMOI_DIR}" bash "${CHEZMOI_DIR}/workspace/scripts/upgrade.sh"
LINE_COUNT_FINAL="$(wc -l <"${HOME}/.bashrc")"
BASHRC_CAT_FINAL="$(cat "${HOME}/.bashrc")"
printf "info: checking if upgrade was idempotent... "
if [[ "${LINE_COUNT_START}" -ne "${LINE_COUNT_FINAL}" ]]; then
  echo "FAILED"
  diff -y <(echo "${BASHRC_CAT_START}") <(echo "${BASHRC_CAT_FINAL}")
  exit 1
else
  echo "PASSED"
fi

# End tests
echo "info: all tests PASSED"

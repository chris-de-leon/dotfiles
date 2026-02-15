#!/usr/bin/env bash

set -eo pipefail

if [[ -z "${DOTFILES_REPO_PATH}" ]]; then
  echo "error: environment variable 'DOTFILES_REPO_PATH' must be provided" && exit 1
fi

# shellcheck source=/dev/null
. "${DOTFILES_REPO_PATH}/dev/lib/assertions.sh"

# shellcheck source=/dev/null
. "${DOTFILES_REPO_PATH}/dev/lib/stubs.sh"

# shellcheck source=/dev/null
. "${DOTFILES_REPO_PATH}/dev/lib/utils.sh"

test_main() {
  # shellcheck disable=SC2016 # Single quotes are intentional - expression should not be expanded
  local dkinit='if command -v devkit &>/dev/null; then eval "$(devkit init)"; fi'
  local nixlnk="${HOME}/.nix-profile"
  local gitcfg="${HOME}/.gitconfig"
  local dotcfg="${HOME}/.config"
  local bashrc="${HOME}/.bashrc"

  # Verify that `util_use_sandbox_configs` created .gitconfig
  assert_file_exists "${gitcfg}"

  # NOTE: we want to avoid installing these tools in the container,
  # so we create some stubs in place of the actual tools. This will
  # cause the devkit CLI to think that they are already present on
  # the system and skip their installation.
  create_stub "tailscale"
  create_stub "docker"

  # Verify that nothing is installed yet
  assert_line_not_exists "${bashrc}" "${dkinit}"
  assert_link_not_exists "${dotcfg}/starship.toml"
  assert_link_not_exists "${dotcfg}/tmux"
  assert_link_not_exists "${dotcfg}/nvim"
  assert_link_not_exists "${nixlnk}"
  util_run_install_script "${DOTFILES_REPO_PATH}"
  assert_line_exists "${bashrc}" "${dkinit}"
  assert_link_exists "${dotcfg}/starship.toml"
  assert_link_exists "${dotcfg}/tmux"
  assert_link_exists "${dotcfg}/nvim"
  assert_link_exists "${nixlnk}"

  # Verify that the default nix profile symlink is available after install
  printf "info: reading nix profile symlink... "
  local nixdir="" && nixdir="$(readlink "${nixlnk}")"
  echo "PASSED"

  # Verify that the devenv bashrc init script exists at the expected path
  assert_file_exists "${nixdir}/etc/profile.d/init"

  # The Nix daemon is not online yet, so `nix` shouldn't be available
  assert_cmd_not_exists "nix"

  # shellcheck source=/dev/null # Activate the Nix daemon
  . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

  # Verify that dev env tools are available now
  assert_cmd_exists "starship"
  assert_cmd_exists "devkit"
  assert_cmd_exists "tmux"
  assert_cmd_exists "nvim"
  assert_cmd_exists "nix"
  assert_cmd_exists "jq"
  assert_cmd_exists "gh"

  # Verify that the gitauth command properly configures .gitconfig
  test_main_gitauth() {
    local tmpvar=""
    git config --global init.defaultBranch ""
    git config --global core.editor ""
    git config --global user.email ""
    git config --global user.name ""

    tmpvar="$(git config --global --get init.defaultBranch)"
    assert_empty "git config init.defaultBranch" "${tmpvar}"
    tmpvar="$(git config --global --get core.editor)"
    assert_empty "git config core.editor" "${tmpvar}"
    tmpvar="$(git config --global --get user.email)"
    assert_empty "git config user.email" "${tmpvar}"
    tmpvar="$(git config --global --get user.name)"
    assert_empty "git config user.name" "${tmpvar}"

    devkit gitauth

    tmpvar="$(git config --global --get user.email)"
    assert_not_empty "git config user.email" "${tmpvar}"
    tmpvar="$(git config --global --get user.name)"
    assert_not_empty "git config user.name" "${tmpvar}"
    tmpvar="$(git config --global --get init.defaultBranch)"
    assert_eq "master" "${tmpvar}"
    tmpvar="$(git config --global --get core.editor)"
    assert_eq "vim" "${tmpvar}"
  }

  # Verify that the CLI skips the installation of these tools since they
  # already exist on the machine (we added stubs for them earlier above)
  test_main_install() {
    devkit install --tailscale --docker
  }

  # This command is invoked by the install script - we verify that
  # calling it again causes no errors (it should be idempotent)
  test_main_migrate() {
    devkit migrate
  }

  # Verify that a non-empty version is returned
  test_main_version() {
    local tmpvar && tmpvar="$(devkit version)"
    assert_not_empty "devkit version" "${tmpvar}"
  }

  # Verify that the profile path is correct
  test_main_profile() {
    local tmpvar && tmpvar="$(devkit profile)"
    assert_eq "${nixdir}" "${tmpvar}"
  }

  # Verify that the devkit home directory is correct
  test_main_home() {
    local tmpvar && tmpvar="$(devkit home)"
    assert_eq "$(dirname "${DOTFILES_REPO_PATH}")" "${tmpvar}"
  }

  # Run all subtests
  test_main_gitauth
  test_main_install
  test_main_migrate
  test_main_version
  test_main_profile
  test_main_home
}

echo ""
echo "info: ========================"
echo "info: running testing suite..."
echo "info: ========================"
echo ""

util_use_sandbox_configs "${DOTFILES_REPO_PATH}"
test_main

echo ""
echo "info: ================"
echo "info: all tests PASSED"
echo "info: ================"
echo ""

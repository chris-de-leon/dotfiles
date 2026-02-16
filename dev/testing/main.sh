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
  local nixdir=""

  # Verify that `util_use_sandbox_configs` creates a .gitconfig
  assert_file_not_exists "${gitcfg}"
  util_use_sandbox_configs "${DOTFILES_REPO_PATH}"
  assert_file_exists "${gitcfg}"

  # NOTE: we want to avoid installing these tools in the container,
  # so we create some stubs in place of the actual tools. This will
  # cause the devkit CLI to think that they are already present on
  # the system and skip their installation.
  create_stub "tailscale"
  create_stub "docker"

  # Verify that the install script works as intended
  test_main_installation() {
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

    nixdir="$(readlink "${nixlnk}")"
    assert_file_exists "${nixdir}/etc/profile.d/init"
  }

  # Verify that dev env tools are available (after the nix daemon is activated)
  test_main_tools_exist() {
    assert_cmd_not_exists "starship"
    assert_cmd_not_exists "lazygit"
    assert_cmd_not_exists "devkit"
    assert_cmd_not_exists "tmux"
    assert_cmd_not_exists "nvim"
    assert_cmd_not_exists "vim"
    assert_cmd_not_exists "nix"
    assert_cmd_not_exists "jq"
    assert_cmd_not_exists "gh"

    # shellcheck source=/dev/null
    . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"

    assert_cmd_exists "starship"
    assert_cmd_exists "lazygit"
    assert_cmd_exists "devkit"
    assert_cmd_exists "tmux"
    assert_cmd_exists "nvim"
    assert_cmd_exists "vim"
    assert_cmd_exists "nix"
    assert_cmd_exists "jq"
    assert_cmd_exists "gh"
  }

  # Verify that the gitauth command properly configures .gitconfig
  test_main_dk_gitauth() {
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
  test_main_dk_install() {
    devkit install --tailscale --docker
  }

  # This command is invoked by the install script - we verify that
  # calling it again causes no errors (it should be idempotent)
  test_main_dk_migrate() {
    devkit migrate
  }

  # Verify that a non-empty version is returned
  test_main_dk_version() {
    local tmpvar && tmpvar="$(devkit version)"
    assert_not_empty "devkit version" "${tmpvar}"
  }

  # Verify that the profile path is correct
  test_main_dk_profile() {
    local tmpvar && tmpvar="$(devkit profile)"
    assert_eq "${nixdir}" "${tmpvar}"
  }

  # Verify that the devkit home directory is correct
  test_main_dk_home() {
    local tmpvar && tmpvar="$(devkit home)"
    assert_eq "$(dirname "${DOTFILES_REPO_PATH}")" "${tmpvar}"
  }

  # Run all subtests
  test_main_installation
  test_main_tools_exist
  test_main_dk_gitauth
  test_main_dk_install
  test_main_dk_migrate
  test_main_dk_version
  test_main_dk_profile
  test_main_dk_home
}

echo ""
echo "info: ========================"
echo "info: running testing suite..."
echo "info: ========================"
echo ""

test_main

echo ""
echo "info: ================"
echo "info: all tests PASSED"
echo "info: ================"
echo ""

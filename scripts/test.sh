#!/usr/bin/env bash

set -eo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 && pwd -P)"

# shellcheck source=/dev/null
. "${SCRIPT_DIR}/lib/assertions.sh"

# shellcheck source=/dev/null
. "${SCRIPT_DIR}/lib/stubs.sh"

# shellcheck source=/dev/null
. "${SCRIPT_DIR}/lib/util.sh"

run_test() {
  echo ""
  echo "info: ============================================"
  echo "info: Running '${1}'..."
  echo "info: ============================================"
  echo ""
  "${1}"
}

test_dotfiles() {
  local nix_lnk="${HOME}/.nix-profile"
  local nix_dir=""
  local dev_dir=""
  local dev_ini=""
  local dev_bin=""

  assert_link_not_exists "${HOME}/.config/starship.toml"
  assert_link_not_exists "${HOME}/.config/tmux"
  assert_link_not_exists "${HOME}/.config/nvim"
  assert_link_not_exists "${nix_lnk}"

  util_run_install_script

  assert_link_exists "${HOME}/.config/starship.toml"
  assert_link_exists "${HOME}/.config/tmux"
  assert_link_exists "${HOME}/.config/nvim"
  assert_link_exists "${nix_lnk}"

  printf "info: reading nix profile symlink... "
  nix_dir="$(readlink "${nix_lnk}")"
  dev_dir="$(dirname "${nix_dir}")/dev"
  dev_ini="${dev_dir}/etc/profile.d/init"
  echo "PASSED"

  assert_line_exists "${HOME}/.bashrc" "if [[ -f \"${dev_ini}\" ]]; then . \"${dev_ini}\"; fi"
  assert_file_exists "${dev_ini}"

  assert_cmd_not_exists "nix"
  . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
  assert_cmd_exists "nix"

  dev_bin="${dev_dir}/bin"
  assert_dir_exists "${dev_bin}"
  export PATH="${dev_bin}:${PATH}"

  assert_cmd_exists "starship"
  assert_cmd_exists "devkit"
  assert_cmd_exists "stow"
  assert_cmd_exists "tmux"
  assert_cmd_exists "nvim"
  assert_cmd_exists "jq"
  assert_cmd_exists "gh"

  devkit version
  devkit profile
  devkit refresh
  devkit cfgdirs
  devkit cfgpath
  devkit unstow
  devkit restow
  devkit hist
  devkit list
  devkit home
}

test_tools() {
  # NOTE: this won't actually install any tools in the container - instead
  # we'll create some stubs in place of the actual tools and test that the
  # setup script is detecting that they are already present on the system
  create_stub "tailscale"
  create_stub "docker"
  util_run_install_script --tailscale --docker
}

test_git() {
  local gitconfig="${HOME}/.gitconfig"
  assert_file_not_exists "${gitconfig}"
  util_run_install_script --git
  assert_file_exists "${gitconfig}"
}

test_all() {
  util_run_install_script --tailscale --docker --git
}

echo ""
echo "info: ========================"
echo "info: running testing suite..."
echo "info: ========================"
echo ""

util_setup_container
run_test test_dotfiles
run_test test_tools
run_test test_git
run_test test_all

echo ""
echo "info: ================"
echo "info: all tests PASSED"
echo "info: ================"
echo ""

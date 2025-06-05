#!/usr/bin/env bash

assert_dir_not_exists() {
  local dirpath="${1:-}"
  printf "info: checking that directory '%s' does not exist... " "${dirpath}"
  if [[ -d "${dirpath}" ]]; then
    echo "FAILED" && exit 1
  else
    echo "PASSED"
  fi
}

assert_file_not_exists() {
  local filepath="${1:-}"
  printf "info: checking that file '%s' does not exist... " "${filepath}"
  if [[ -f "${filepath}" ]]; then
    echo "FAILED" && exit 1
  else
    echo "PASSED"
  fi
}

assert_line_not_exists() {
  local filepath="${1:-}"
  local line="${2:-}"

  printf "info: checking that line '%s' does not exist in '%s'... " "${line}" "${filepath}"
  if grep -Fxq "${line}" "${filepath}"; then
    echo "FAILED" && exit 1
  else
    echo "PASSED"
  fi
}

assert_link_not_exists() {
  local linkpath="${1:-}"
  printf "info: checking that symlink '%s' does not exist... " "${linkpath}"
  if [[ -L "${linkpath}" ]]; then
    echo "FAILED" && exit 1
  else
    echo "PASSED"
  fi
}

assert_dir_exists() {
  local dirpath="${1:-}"
  printf "info: checking that directory '%s' exists... " "${dirpath}"
  if [[ -d "${dirpath}" ]]; then
    echo "PASSED"
  else
    echo "FAILED" && exit 1
  fi
}

assert_file_exists() {
  local filepath="${1:-}"
  printf "info: checking that file '%s' exists... " "${filepath}"
  if [[ -f "${filepath}" ]]; then
    echo "PASSED"
  else
    echo "FAILED" && exit 1
  fi
}

assert_line_exists() {
  local filepath="${1:-}"
  local line="${2:-}"

  printf "info: checking that line '%s' exists in '%s'... " "${line}" "${filepath}"
  if grep -Fxq "${line}" "${filepath}"; then
    echo "PASSED"
  else
    echo "FAILED" && exit 1
  fi
}

assert_link_exists() {
  local linkpath="${1:-}"
  printf "info: checking that symlink '%s' exists... " "${linkpath}"
  if [[ -L "${linkpath}" ]]; then
    echo "PASSED"
  else
    echo "FAILED" && exit 1
  fi
}

create_stub() {
  local name="${1:-}"
  if [[ -z "${name}" ]]; then
    echo "error: stub name is required"
    exit 1
  fi

  local dir="/tmp/stubs"
  mkdir -p "${dir}"

  local stub=""
  stub+="#!/bin/sh"
  stub+="\n"
  stub+="echo '${name} stub invoked'"
  stub+="\n"
  stub+="exit 0"

  printf "info: creating '%s' stub..." "${name}"
  echo -e "${stub}" >"${dir}/${name}"
  chmod +x "${dir}/${name}"
  export PATH="${dir}:${PATH}"
  echo "done"
}

get_nix_profiles_dir() {
  local dir
  dir="$(readlink "${HOME}/.nix-profile")"
  dirname "${dir}"
}

setup_container() {
  # define chezmoi directory
  local chezmoi_dir=""
  chezmoi_dir="$(pwd)/chezmoi"

  # apt configs
  apt update && apt upgrade -y && apt install -y curl git sudo tzdata

  # install Nix: https://github.com/DeterminateSystems/nix-installer?tab=readme-ov-file#without-systemd-linux-only
  # shellcheck disable=SC2312
  curl --proto '=https' --tlsv1.2 -sSf -L 'https://install.determinate.systems/nix/tag/v3.6.2' | sh -s -- install linux --extra-conf "sandbox = false" --init none --no-confirm

  # add `nix` to current shell
  # shellcheck source=/dev/null
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

  # define dev profile paths
  local dev_profile_loc=""
  local dev_profile_bin=""
  dev_profile_loc="$(get_nix_profiles_dir)/dev"
  dev_profile_bin="${dev_profile_loc}/bin"

  # install dev tools
  nix profile install --print-build-logs --profile "${dev_profile_loc}" "path:${chezmoi_dir}"

  # make tools visible on PATH
  export PATH="${dev_profile_bin}:${PATH}"
}

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

run_shellcheck() {
  local filepath="${1:-}"
  printf "info: running shellcheck on file '%s'... " "${filepath}"
  if shellcheck --shell bash --exclude=SC2292,SC1091 -o all "${filepath}"; then
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

  printf "info: creating '%s' stub... " "${name}"
  echo -e "${stub}" >"${dir}/${name}"
  chmod +x "${dir}/${name}"
  export PATH="${dir}:${PATH}"
  echo "done"
}

get_nix_profiles_dir() {
  local dir=""
  dir="$(readlink "${HOME}/.nix-profile")"
  dirname "${dir}"
}

setup_container() {
  # helper var(s)
  local dir=""

  # apt configs
  apt-get update && apt-get upgrade -y && apt-get install -y curl git sudo tzdata

  # get the path to the chezmoi directory
  dir="$(pwd)/chezmoi"

  # install dev tools
  DOTFILES_NIX_URL="path:${dir}" bash "${dir}/workspace/scripts/install.sh"

  # get the path to the dev profile bin
  dir="$(get_nix_profiles_dir)/dev/bin"

  # add dev tools to PATH
  export PATH="${dir}:${PATH}"
}

#!/usr/bin/env bash

assert_dir_not_exists() {
  local dirpath="${1:-}"
  printf "info: checking that '%s' does not exist... " "${dirpath}"
  if [[ -d "${dirpath}" ]]; then
    echo "FAILED" && exit 1
  else
    echo "PASSED"
  fi
}

assert_file_not_exists() {
  local filepath="${1:-}"
  printf "info: checking that '%s' does not exist... " "${filepath}"
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

assert_dir_exists() {
  local dirpath="${1:-}"
  printf "info: checking that '%s' exists... " "${dirpath}"
  if [[ -d "${dirpath}" ]]; then
    echo "PASSED"
  else
    echo "FAILED" && exit 1
  fi
}

assert_file_exists() {
  local filepath="${1:-}"
  printf "info: checking that '%s' exists... " "${filepath}"
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

  printf "info: creating '%s' stub..." "${stub}"
  echo -e "${stub}" >"${dir}/${name}"
  chmod +x "${dir}/${name}"
  export PATH="${dir}:${PATH}"
  echo "done"
}

setup_container() {
  # define chezmoi directory
  local chezmoi_dir=""
  chezmoi_dir="$(pwd)/chezmoi"

  # apt configs
  apt update && apt upgrade -y && apt install -y curl git sudo tzdata

  # shellcheck disable=SC2312
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux --extra-conf "sandbox = false" --init none --no-confirm

  # shellcheck source=/dev/null
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

  # install dev tools
  nix profile install "path:${chezmoi_dir}"
}

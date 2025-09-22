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

assert_dir_exists() {
  local dirpath="${1:-}"
  printf "info: checking that directory '%s' exists... " "${dirpath}"
  if [[ -d "${dirpath}" ]]; then
    echo "PASSED"
  else
    echo "FAILED" && exit 1
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

assert_file_exists() {
  local filepath="${1:-}"
  printf "info: checking that file '%s' exists... " "${filepath}"
  if [[ -f "${filepath}" ]]; then
    echo "PASSED"
  else
    echo "FAILED" && exit 1
  fi
}

assert_line_not_exists() {
  local filepath="${1:-}"
  local line="${2:-}"

  printf "info: checking that line '%s' does not exist in '%s'... " "${line}" "${filepath}"
  if grep -Fxq "${line}" "${filepath}"; then
    echo "FAILED"
    cat "${filepath}"
    exit 1
  else
    echo "PASSED"
  fi
}

assert_line_exists() {
  local filepath="${1:-}"
  local line="${2:-}"

  printf "info: checking that line '%s' exists in '%s'... " "${line}" "${filepath}"
  if grep -Fxq "${line}" "${filepath}"; then
    echo "PASSED"
  else
    echo "FAILED"
    cat "${filepath}"
    exit 1
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

assert_link_exists() {
  local linkpath="${1:-}"
  printf "info: checking that symlink '%s' exists... " "${linkpath}"
  if [[ -L "${linkpath}" ]]; then
    echo "PASSED"
  else
    echo "FAILED" && exit 1
  fi
}

assert_cmd_not_exists() {
  local cmd="${1:-}"
  printf "info: checking that command '%s' does not exist... " "${cmd}"
  if command -v "${cmd}" &>/dev/null; then
    echo "FAILED" && exit 1
  else
    echo "PASSED"
  fi
}

assert_cmd_exists() {
  local cmd="${1:-}"
  printf "info: checking that command '%s' exists... " "${cmd}"
  if command -v "${cmd}" &>/dev/null; then
    echo "PASSED"
  else
    echo "FAILED" && exit 1
  fi
}

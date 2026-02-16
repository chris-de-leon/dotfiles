#!/usr/bin/env bash

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

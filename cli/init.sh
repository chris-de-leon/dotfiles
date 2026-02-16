#!/usr/bin/env bash

if command -v starship &>/dev/null; then
  STARSHIP_INIT="$(starship init bash)"
  eval "${STARSHIP_INIT}"
fi

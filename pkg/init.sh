#!/usr/bin/env bash
# shellcheck disable=SC2292 # We intentionally use [ ] over [[ ]] for portability

if [ -L "${HOME}/.nix-profile" ]; then
  NIX_PROFILE_DIR="$(readlink "${HOME}/.nix-profile")"
  DEV_PROFILE_BIN="$(dirname "${NIX_PROFILE_DIR}")/dev/bin"
  if [ -d "${DEV_PROFILE_BIN}" ]; then
    # Adds the dev profile to PATH, which makes all developer tools
    # defined in `flake.nix` available to the current shell session
    export PATH="${DEV_PROFILE_BIN}:${PATH}"
  fi
fi

if command -v starship &>/dev/null; then
  STARSHIP_INIT="$(starship init bash)"
  eval "${STARSHIP_INIT}"
fi

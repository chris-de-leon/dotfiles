#!/usr/bin/env bash

set -eo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 && pwd -P)"

# shellcheck source=/dev/null
. "${SCRIPT_DIR}/lib/util.sh"

util_setup_container
util_setup_default_profile

exec bash

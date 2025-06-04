#!/usr/bin/env bash

set -eo pipefail

# Import test utils
SCRIPT_DIR="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 && pwd -P)"

# shellcheck source=/dev/null
. "${SCRIPT_DIR}/util.sh"

# Prevent certain tools from being installed inside the container
create_stub "tailscale"
create_stub "docker"

# Setup the container
setup_container

# Begin sandbox env
echo "=============================================="
echo "Sandbox environment is ready!"
echo "To get started, try running the command below:"
echo "chezmoi init --apply"
echo "=============================================="

# Start an interactive bash session
echo ""
cd ./chezmoi && exec bash

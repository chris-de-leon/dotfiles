#!/usr/bin/env bash

set -eo pipefail

sudo apt-get --fix-broken install -y
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y qemu-user-static
sudo apt-get autoremove -y

if ! command -v tailscale &>/dev/null; then
  curl -fsSL 'https://tailscale.com/install.sh' | sh
fi

if ! command -v docker &>/dev/null; then
  curl -fsSL 'https://get.docker.com' | sh
  sudo usermod -aG docker "${USER}"
fi

set -e

nix \
  --extra-experimental-features 'flakes' \
  --extra-experimental-features 'nix-command' \
  develop \
  --show-trace

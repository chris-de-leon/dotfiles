docker run --rm \
  -v ~/.gitconfig:/root/.gitconfig \
  -v ~/.bashrc:/root/.bashrc \
  -v $(pwd):/root/dotfiles \
  -e "TERM=$TERM" \
  -e "LANG=C.UTF-8" \
  -e "LC_ALL=C.UTF-8" \
  -e "LC_CTYPE=C.UTF-8" \
  -it \
  --entrypoint bash \
  nixos/nix:2.23.1

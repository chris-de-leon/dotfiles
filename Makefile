NIX_PROFILE_DIR = $(PWD)/workspace/dist/profiles
MAKEFLAGS += --no-print-directory
SHELL = /bin/bash -eo pipefail
UBUNTU_VERSION = 24.04
NIX_VERSION = 2.29.0

.PHONY: dotfiles
dotfiles:
	chezmoi add "$${HOME}/.config/starship.toml"
	chezmoi add "$${HOME}/.config/tmux"
	chezmoi add "$${HOME}/.config/nvim"

.PHONY: shellcheck
shellcheck:
	find . -type f -name "*.sh" -print -exec shellcheck -o all {} +

.PHONY: chezshow
chezshow:
	chezmoi execute-template '{{ .chezmoi | toJson }}' | jq

.PHONY: lint
lint: shellcheck
lint: nixcheck
lint:
	@echo "All files passed lint check ✅"

.PHONY: test
test: CONTAINER_NAME := "chezmoi-test"
test:
	@docker container rm $(CONTAINER_NAME) || exit 0
	@docker container create --rm \
		-e DEBIAN_FRONTEND="noninteractive" \
		-e DOCKERHUB_USERNAME="dummy-username" \
		-e DOCKERHUB_PASSWORD="dummy-password" \
		-e GITHUB_TOKEN="$${GITHUB_TOKEN}" \
		-e TF_TOKEN="dummy-token" \
		-e TZ=America/Los_Angeles \
		-w /root/.local/share \
		--name $(CONTAINER_NAME) \
		ubuntu:$(UBUNTU_VERSION) \
		bash ./chezmoi/workspace/scripts/linux/ubuntu/docker/test.sh
	@docker cp $(PWD) $(CONTAINER_NAME):/root/.local/share/chezmoi
	@docker container start -a $(CONTAINER_NAME)

.PHONY: sandbox
sandbox: CONTAINER_NAME := "chezmoi-sandbox"
sandbox:
	@docker container rm $(CONTAINER_NAME) || exit 0
	@docker container create --rm -it \
		-e DEBIAN_FRONTEND="noninteractive" \
		-e DOCKERHUB_USERNAME="dummy-username" \
		-e DOCKERHUB_PASSWORD="dummy-password" \
		-e GITHUB_TOKEN="$${GITHUB_TOKEN}" \
		-e TF_TOKEN="dummy-token" \
		-e TZ=America/Los_Angeles \
		-w /root/.local/share \
		--name $(CONTAINER_NAME) \
		ubuntu:$(UBUNTU_VERSION) \
		bash ./chezmoi/workspace/scripts/linux/ubuntu/docker/sandbox.sh
	@docker cp $(PWD) $(CONTAINER_NAME):/root/.local/share/chezmoi
	@docker container start -ai $(CONTAINER_NAME)

.PHONY: nixshell
nixshell:
	@if [ -z "$$CI" ]; then \
		nix shell \
			'github:NixOS/nixpkgs/nixos-25.05#bitwarden-cli' \
			'github:NixOS/nixpkgs/nixos-25.05#shellcheck' \
			'github:NixOS/nixpkgs/nixos-25.05#chezmoi' \
			'github:NixOS/nixpkgs/nixos-25.05#nodejs' \
			'github:NixOS/nixpkgs/nixos-25.05#gh' \
			--command bash; \
	else \
		nix profile install \
			'github:NixOS/nixpkgs/nixos-25.05#shellcheck' \
			'github:NixOS/nixpkgs/nixos-25.05#chezmoi'; \
	fi

.PHONY: nixprofile
nixprofile:
	@rm -rf $(NIX_PROFILE_DIR) && mkdir -p $(NIX_PROFILE_DIR)
	@nix profile install --print-build-logs --refresh --profile $(NIX_PROFILE_DIR)/dev .
	@du -shL $(NIX_PROFILE_DIR)/dev/bin

.PHONY: nixcheck
nixcheck:
	nix run '.#fmt' -- --check .

.PHONY: nixshow
nixshow:
	nix flake show

.PHONY: nixlock
nixlock:
	nix flake lock

.PHONY: nixfmt
nixfmt:
	nix fmt .

.PHONY: nixbox
nixbox: CONTAINER_NAME := "nixbox"
nixbox:
	@docker container rm $(CONTAINER_NAME) || exit 0
	@docker container create --rm -it \
		-e NIX_CONFIG="experimental-features = nix-command flakes" \
		-w /root/.local/share \
		--name $(CONTAINER_NAME) \
		nixos/nix:$(NIX_VERSION) \
		bash ./chezmoi/workspace/scripts/nix/docker/sandbox.sh
	@docker cp $(PWD) $(CONTAINER_NAME):/root/.local/share
	@docker container start -ai $(CONTAINER_NAME)


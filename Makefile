MAKEFLAGS += --no-print-directory
MAKEFLAGS += --output-sync=target

.SHELLFLAGS := -eo pipefail -c
SHELL := /bin/bash

UBUNTU_VERSION := 24.04
NIX_VERSION := 2.31.1

.PHONY: configs
configs: DIR := "configs"
configs:
	rm -rf $(DIR)
	mkdir -p $(DIR)/starship/.config && cp "$${HOME}/.config/starship.toml" $(DIR)/starship/.config
	mkdir -p $(DIR)/nvim/.config && cp -r "$${HOME}/.config/nvim" $(DIR)/nvim/.config
	mkdir -p $(DIR)/tmux/.config && cp -r "$${HOME}/.config/tmux" $(DIR)/tmux/.config

.PHONY: shlint
shlint:
	find . -type f -name "*.sh" -print -exec shellcheck -o all {} +

.PHONY: lint
lint: nixlint
lint: shlint
lint:
	@echo "All files passed lint check ✅"

.PHONY: test
test: REPO_DEST_PATH := "/root/.local/share/chris-de-leon/dotfiles"
test: CONTAINER_NAME := "dotfiles-test"
test:
	@docker container rm $(CONTAINER_NAME) || exit 0
	@docker container create --rm \
		-e DEBIAN_FRONTEND="noninteractive" \
		-e DOTFILES_INSTALLER="$(REPO_DEST_PATH)/install.sh" \
		-e DOTFILES_REPO_PATH="$(REPO_DEST_PATH)" \
		-e GITHUB_TOKEN="$${GITHUB_TOKEN}" \
		-e TZ=America/Los_Angeles \
		-w $(REPO_DEST_PATH) \
		--name $(CONTAINER_NAME) \
		ubuntu:$(UBUNTU_VERSION) \
		bash ./scripts/test.sh
	@docker cp $(PWD) $(CONTAINER_NAME):$$(dirname $(REPO_DEST_PATH))
	@docker container start -a $(CONTAINER_NAME)

.PHONY: sandbox
sandbox: REPO_DEST_PATH := "/root/.local/share/chris-de-leon/dotfiles"
sandbox: CONTAINER_NAME := "dotfiles-sandbox"
sandbox:
	@docker container rm $(CONTAINER_NAME) || exit 0
	@docker container create --rm -it \
		-e DEBIAN_FRONTEND="noninteractive" \
		-e DOTFILES_INSTALLER="$(REPO_DEST_PATH)/install.sh" \
		-e DOTFILES_REPO_PATH="$(REPO_DEST_PATH)" \
		-e GITHUB_TOKEN="$${GITHUB_TOKEN}" \
		-e TZ=America/Los_Angeles \
		-w $(REPO_DEST_PATH) \
		--name $(CONTAINER_NAME) \
		ubuntu:$(UBUNTU_VERSION) \
		bash ./scripts/sandbox.ubuntu.sh
	@docker cp $(PWD) $(CONTAINER_NAME):$$(dirname $(REPO_DEST_PATH))
	@docker container start -ai $(CONTAINER_NAME)

.PHONY: nixshell
nixshell:
	@if [ -z "$$CI" ]; then \
		nix shell \
			'github:NixOS/nixpkgs/nixos-25.05#shellcheck' \
			'github:NixOS/nixpkgs/nixos-25.05#nodejs' \
			'github:NixOS/nixpkgs/nixos-25.05#cargo' \
			'github:NixOS/nixpkgs/nixos-25.05#gh' \
			--command bash; \
	else \
		nix profile add \
			'github:NixOS/nixpkgs/nixos-25.05#shellcheck'; \
	fi

.PHONY: nixprofile
nixprofile: NIX_PROFILE_DIR := $(PWD)/dist/profiles
nixprofile:
	@rm -rf $(NIX_PROFILE_DIR) && mkdir -p $(NIX_PROFILE_DIR)
	@nix profile add --print-build-logs --refresh --profile $(NIX_PROFILE_DIR)/dev .
	@du -shL $(NIX_PROFILE_DIR)/dev/bin

.PHONY: nixupdate
nixupdate:
	nix flake update

.PHONY: nixshow
nixshow:
	nix flake show

.PHONY: nixlint
nixlint:
	nix run '.#fmt' -- --check .

.PHONY: nixlock
nixlock:
	nix flake lock

.PHONY: nixfmt
nixfmt:
	nix fmt .

.PHONY: nixbox
nixbox: REPO_DEST_PATH := "/root/.local/share/chris-de-leon/dotfiles"
nixbox: CONTAINER_NAME := "nixbox"
nixbox:
	@docker container rm $(CONTAINER_NAME) || exit 0
	@docker container create --rm -it \
		-e NIX_CONFIG="experimental-features = nix-command flakes" \
		-e DOTFILES_INSTALLER="$(REPO_DEST_PATH)/install.sh" \
		-e DOTFILES_REPO_PATH="$(REPO_DEST_PATH)" \
		-e GITHUB_TOKEN="$${GITHUB_TOKEN}" \
		-w $(REPO_DEST_PATH) \
		--name $(CONTAINER_NAME) \
		nixos/nix:$(NIX_VERSION) \
		bash ./scripts/sandbox.nix.sh
	@docker cp $(PWD) $(CONTAINER_NAME):$$(dirname $(REPO_DEST_PATH))
	@docker container start -ai $(CONTAINER_NAME)


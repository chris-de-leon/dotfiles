MAKEFLAGS += --no-print-directory
MAKEFLAGS += --output-sync=target

.SHELLFLAGS := -eo pipefail -c
SHELL := /bin/bash

UBUNTU_VERSION := 24.04
NIX_VERSION := 2.33.1

.PHONY: sandbox.ubuntu
sandbox.ubuntu: MAIN ?= ./dev/sandbox/ubuntu/entrypoint.sh
sandbox.ubuntu: OPTS ?= -it
sandbox.ubuntu:
	$(MAKE) sandbox VERSION="$(UBUNTU_VERSION)" \
	  OPTS="$(OPTS)" MAIN="$(MAIN)" \
		FILE="./dev/sandbox/ubuntu/Dockerfile" \
		NAME="dotfiles.sandbox.ubuntu" \
		IMG="dotfiles:sandbox-ubuntu"

.PHONY: sandbox.nix
sandbox.nix: MAIN ?= ./dev/sandbox/nix/entrypoint.sh
sandbox.nix: OPTS ?= -it
sandbox.nix:
	$(MAKE) sandbox VERSION="$(NIX_VERSION)" \
	  OPTS="$(OPTS)" MAIN="$(MAIN)" \
		FILE="./dev/sandbox/nix/Dockerfile" \
		NAME="dotfiles.sandbox.nix" \
		IMG="dotfiles:sandbox-nix"

.PHONY: sandbox
sandbox: export GH_TOKEN := $(shell gh auth token)
sandbox: REPO := /root/.devkit/dotfiles
sandbox: OPTS ?=
sandbox:
	docker build --build-arg VERSION="$(VERSION)" --build-arg WORKDIR="$(REPO)" --tag "$(IMG)" -f "$(FILE)" .
	docker container create --rm --name "$(NAME)" -e GH_TOKEN="$${GH_TOKEN}" $(OPTS) "$(IMG)" bash "$(MAIN)"
	docker cp "$(PWD)/." "$(NAME):$(REPO)"
	docker container start -ai "$(NAME)"

.PHONY: lint
lint: nixlint
lint:
	@find . -type f -name "*.sh" -print -exec shellcheck -o all {} +
	@echo "All files passed lint check ✅"

.PHONY: test
test:
	$(MAKE) sandbox.ubuntu OPTS="" MAIN="./dev/testing/main.sh"

.PHONY: cfg
cfg: DIR := cfg
cfg:
	rm -rf "$(DIR)"
	mkdir -p "$(DIR)/starship/.config" && cp -L "$${HOME}/.config/starship.toml" "$(DIR)/starship/.config"
	mkdir -p "$(DIR)/nvim/.config" && cp -Lr "$${HOME}/.config/nvim" "$(DIR)/nvim/.config"
	mkdir -p "$(DIR)/tmux/.config" && cp -Lr "$${HOME}/.config/tmux" "$(DIR)/tmux/.config"

.PHONY: bin
bin: DIR := $(PWD)/dist/profiles
bin:
	@rm -rf "$(DIR)" && mkdir -p "$(DIR)"
	@nix profile add --print-build-logs --refresh --profile "$(DIR)/dev" .
	@du -shL "$(DIR)/dev/bin"

.PHONY: sh
sh:
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

.PHONY: nixupdate
nixupdate:
	nix flake update

.PHONY: nixrepl
nixrepl:
	nix repl --expr 'import <nixpkgs>{}'

.PHONY: nixlint
nixlint:
	nix fmt . -- --check .

.PHONY: nixshow
nixshow:
	nix flake show

.PHONY: nixlock
nixlock:
	nix flake lock

.PHONY: nixfmt
nixfmt:
	nix fmt .


# Dotfiles

<div>
  <a href="https://github.com/chris-de-leon/dotfiles/actions">
  <img src="https://github.com/chris-de-leon/dotfiles/actions/workflows/release.yaml/badge.svg"/>
 </a>
</div>

### Introduction

This repository provides a cross-platform development environment with dotfiles and a curated set of open-source tools. Everything is packaged with Nix for reproducibility, while dotfiles are versioned with Git. The environment is pre-configured with sensible defaults but still leaves room for customization.

### Development Stack

The `flake.nix` is the source of truth describing all packages that will be included in the development environment. Here is a snippet of some of the core tools included:

- [Neovim](https://github.com/neovim/neovim) + [LazyVim](https://www.lazyvim.org/)
- [Starship](https://starship.rs/)
- [LazyGit](https://github.com/jesseduffield/lazygit)
- [tmux](https://github.com/tmux/tmux)

## Recommended Terminal + VM Setup

### MacOS & Linux

1. Install [Multipass](https://canonical.com/multipass/install) (on Ubuntu Desktop this can be installed from the App Center)

1. Install [Alacritty](https://github.com/alacritty/alacritty/releases) (on Ubuntu Desktop this can be installed from the App Center)

1. Follow the guide [here](./doc/alacritty.md) to configure Alacritty

1. Open an Alacritty terminal and create a new multipass VM:

   ```sh
   # values are for illustration purposes only
   multipass launch 24.04 --name=dev --cpus=12 --memory=30G --disk=100G
   ```

1. Start a shell session in the VM:

   ```sh
   multipass shell dev
   ```

### WSL

1. Follow the guide [here](./doc/wsl.md) to setup WSL

1. Install [Alacritty](https://github.com/alacritty/alacritty/releases)

1. Follow the guide [here](./doc/alacritty.md) to configure Alacritty

1. Open an Alacritty terminal to enter WSL

## Installation

Once you have a terminal and VM installed, you can setup the entire development environment with one command. You can safely re-run the command multiple times (and even with different flags) without any unintended consequences on the end state. After running it the first time, make sure that you exit your current shell session and create a new one for the changes to take effect.

### Quick Install

To setup a basic development environment with pre-configured dotfiles, you can use the command below:

```sh
bash <(curl -fsSL 'https://raw.githubusercontent.com/chris-de-leon/dotfiles/master/install.sh')
```

After running this command, exit and re-enter your shell so that the changes are applied.

### Configuration

If you'd also like to opt-in to installing popular tools like Docker and have your Git config populated with sensible defaults, then you can use the following commands:

```sh
# Configure git
devkit gitauth

# Install docker and tailscale
devkit install --docker --tailscale
```

## CLI

After running the install script, you'll have access to `devkit` - a CLI program that helps simplify the management of the development environment. Here are some simple commands that you can run:

```bash
devkit install # Install other popular dev tools like docker and tailscale
devkit migrate # Migrates the devenv to the latest version (or a specific commit)
devkit gitauth # Authenticates to GitHub and configures the git CLI
devkit profile # Shows the path to the nix profile where the devenv lives
devkit version # Shows the CLI version
devkit home    # Shows the path to the .devkit directory
devkit init    # Shows the shell commands that will be run from ~/.bashrc
```

## Upgrades

If any new updates are pushed to this repository, then you can pull the latest changes with one command:

```bash
devkit migrate
```

If you'd like to use a specific version of the development environment, then you can use the command below:

```bash
devkit migrate "dotfiles-repo-commit-hash"
```

If you'd like to upgrade Nix itself, then the following command can help with this:

```bash
sudo determinate-nixd upgrade
```

## Uninstalling

If you're using a VM, the most straightforward approach to uninstall everything would be to back up your files, create a new VM, and add them there. This will fully ensure that no remnants of the dev environment are present. However, if you'd prefer not to do this, then the steps would be:

1. Remove the devkit directory: `rm -rf "$(devkit home)"`
1. Clean up symlinks: `find ~/.config -xtype l -delete`
1. Remove the line that activates the dev environment from `~/.bashrc`
1. Exit and re-open the terminal
1. Remove the dotfiles Nix profile: `nix profile remove --all`
1. Uninstall Nix: `/nix/nix-installer uninstall`
1. Uninstall any other tools (docker, tailscale, etc.)

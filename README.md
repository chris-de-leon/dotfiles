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

1. Follow the guide [here](./docs/alacritty.md) to configure Alacritty

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

1. Follow the guide [here](./docs/wsl.md) to setup WSL

1. Install [Alacritty](https://github.com/alacritty/alacritty/releases)

1. Follow the guide [here](./docs/alacritty.md) to configure Alacritty

1. Open an Alacritty terminal to enter WSL

## Installation

Once you have a terminal and VM installed, you can setup the entire development environment with one command. You can safely re-run the command multiple times (and even with different flags) without any unintended consequences on the end state. After running it the first time, make sure that you exit your current shell session and create a new one for the changes to take effect.

### Quick Install

To setup a basic development environment with pre-configured dotfiles, you can use the command below:

```sh
bash <(curl -fsSL 'https://raw.githubusercontent.com/chris-de-leon/dotfiles/master/install.sh')
```

### Full Install

If you'd also like to opt-in to installing popular tools like Docker and have your Git config populated with sensible defaults, then the following command can be used:

```sh
bash <(curl -fsSL 'https://raw.githubusercontent.com/chris-de-leon/dotfiles/master/install.sh') \
  --tailscale \
  --docker \
  --git
```

## CLI

After running the install script, you'll have access to `devkit` - a CLI program that helps simplify the management of the development environment. Here are some simple commands that you can run:

```bash
devkit version # Shows the CLI version
devkit profile # Shows the path to the Nix profile for the dev environment
devkit cfgdirs # Shows the names of the dotfile config directories
devkit cfgpath # Shows the path to the directory containing the dotfile configs
devkit home    # Shows the path to the dotfiles repository on your local machine
devkit list    # Shows all installed packages in the dev environment
devkit hist    # Shows the dev environment history
```

## Upgrades

If new updates are pushed to this repository, then you can pull them locally with one command:

```bash
devkit migrate
```

If you'd like to use a specific version of the development environment, then you can use the command below:

```bash
devkit rollback "<ref>"
```

If you'd like to upgrade Nix itself, then the following command can help with this:

```bash
sudo determinate-nixd upgrade
```

## Adding/Removing Packages

The development environment has its own Nix profile that you can safely add more packages to. It is recommended to only add packages here that you intend to use globally/frequently otherwise you should consider using a `flake.nix` per project for more fine-grained control. The full list of packages can be found [here](https://search.nixos.org/packages). With that being said, new packages can be added with:

```bash
devkit add "nixpkgs#hello"
```

If you'd like to remove a package later, then the command below can be used:

```bash
devkit del "hello"
```

If you want to ensure a specific package is up to date, then you can use:

```bash
devkit up "hello"
```

All packages can be upgraded using:

```bash
devkit up --all
```

It's important to note that all these commands are aliases / convenience wrappers over the `nix profile` command, so each of these is equivalent to using something like:

```bash
nix profile <action> --profile "$(devkit profile)" ...
```

As a result, [all the documentation for `nix profile`](https://nix.dev/manual/nix/2.30/command-ref/new-cli/nix3-profile.html) applies here including the notes about locked/unlocked flake references.

## Uninstalling

If you're using a VM, the most straightforward approach to uninstall everything would be to back up your files, create a new VM, and add them there. This will fully ensure that no remnants of the dev environment are present. However, if you'd prefer not to do this, then the steps would be:

1. Note down the path to the dev environment's Nix profile: `devkit profile`
1. Clean up the dotfile symlinks: `devkit unstow`
1. Remove the dotfiles repo: `rm -rf "$(devkit home)"`
1. Remove the line that activates the dev environment from `~/.bashrc`
1. Exit and re-open the terminal
1. Remove the dotfiles Nix profile: `nix profile remove --profile "<path to dev env nix profile>" --all`
1. Uninstall Nix: `/nix/nix-installer uninstall`
1. Uninstall any other tools (docker, tailscale, etc.)

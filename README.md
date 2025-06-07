# Dotfiles

<div>
  <a href="https://github.com/chris-de-leon/dotfiles/actions">
  <img src="https://github.com/chris-de-leon/dotfiles/actions/workflows/release.yaml/badge.svg"/>
 </a>
</div>

## Setup

### MacOS, Windows, Linux

1. Create a Github [fine-grained personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token).

1. Install [Multipass](https://canonical.com/multipass/install) (on Ubuntu this can be installed from the App Center)

1. Install [Alacritty](https://github.com/alacritty/alacritty/releases) (on Ubuntu this can be installed from the App Center)

1. Follow the guide [here](./workspace/docs/alacritty.md) to configure Alacritty

1. Open an Alacritty terminal and create a new multipass VM:

   ```sh
   # Values are for display purposes only
   multipass launch 24.04 --name=dev --cpus=12 --memory=30G --disk=100G
   ```

1. Enter the VM:

   ```sh
   multipass shell dev
   ```

### WSL

1. Create a Github [fine-grained personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token).

1. Follow the guide [here](./workspace/docs/wsl.md) to setup WSL

1. Install [Alacritty](https://github.com/alacritty/alacritty/releases)

1. Follow the guide [here](./workspace/docs/alacritty.md) to configure Alacritty

1. Open an Alacritty terminal to enter WSL

## Install

### Default

To install, run the following command:

```sh
GITHUB_TOKEN="<Your GitHub PAT>" bash <(curl -fsSL 'https://raw.githubusercontent.com/chris-de-leon/dotfiles/master/workspace/scripts/install.sh')
```

### Bitwarden

You can also install using Bitwarden:

```sh
DOTFILES_AUTH="bitwarden" BW_CLIENTID="..." BW_CLIENTSECRET="..." bash <(curl -fsSL 'https://raw.githubusercontent.com/chris-de-leon/dotfiles/master/workspace/scripts/install.sh')
```

## Upgrade

To upgrade, run the following command:

```sh
curl -fsSL 'https://raw.githubusercontent.com/chris-de-leon/dotfiles/master/workspace/scripts/upgrade.sh' | bash
```

If using a password manager, please make sure you log in before running this command.

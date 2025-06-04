# WSL

## Install

1. Follow the official installation instructions [here](https://www.docker.com/products/docker-desktop/) to install Docker Desktop if you haven't already
1. Follow the official installation instructions [here](https://learn.microsoft.com/en-us/windows/wsl/install) to install WSL 2 if you haven't already

## Starting Fresh

1. Open a command prompt
1. List the distros available for download: `wsl -l -o`
1. Install an Ubuntu distro using: `wsl --install -d <distro>`

## Upgrading

1. Open a command prompt
1. Make a backup of your files
1. List the distros on your machine: `wsl -l`
1. Uninstall the distro: `wsl --unregister <distro>`
1. List the distros available for download: `wsl -l -o`
1. Install the Ubuntu distro you want: `wsl --install -d <distro>`
1. Make it the default: `wsl --set-default <distro>`

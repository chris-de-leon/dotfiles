# Dotfiles

## Windows + WSL Setup

### Software

Install the following software:

  - [WSL 2](https://learn.microsoft.com/en-us/windows/wsl/install)
  - [Docker Desktop](https://www.docker.com/products/docker-desktop/)
  - [Alacritty](https://github.com/alacritty/alacritty/releases/tag/v0.13.2)

### Setting up WSL

#### Starting Fresh

1. Open a command prompt
1. List the distros available for download: `wsl -l -o`
1. Install the distro of your choice: `wsl --install -d <distro>`
1. Enter a username and password for the distro

#### Upgrading

1. Open a command prompt
1. Make a backup of your files
1. List the distros on your machine: `wsl -l`
1. Uninstall any unnecessary distros: `wsl --unregister <distro>`
1. List the distros available for download: `wsl -l -o`
1. Install the distro of your choice: `wsl --install -d <distro>`
1. Enter a username and password for the distro

### Setting up Alacritty 

Download a [Nerd Font](https://www.nerdfonts.com/) of your choice, then create an `alacritty.toml` file at `Users/<your user>/AppData/Roaming/alacritty/alacritty.toml` with the following values (the font family should be modified accordingly if you chose a font other than CaskaydiaCove):

  ```toml
  [font]
  size = 12.0 # modify as needed

  [font.bold]
  family = "CaskaydiaCove Nerd Font"
  style = "Regular"

  [font.bold_italic]
  family = "CaskaydiaCove Nerd Font"
  style = "Regular"

  [font.italic]
  family = "CaskaydiaCove Nerd Font"
  style = "Regular"

  [font.normal]
  family = "CaskaydiaCove Nerd Font"
  style = "Regular"

  [[keyboard.bindings]]
  action = "Paste"
  key = "V"
  mods = "Control"

  [[keyboard.bindings]]
  action = "Copy"
  key = "C"
  mods = "Control"

  [[keyboard.bindings]]
  chars = "\u0016"
  key = "V"
  mods = "Control|Shift"

  [[keyboard.bindings]]
  chars = "\u0003"
  key = "C"
  mods = "Control|Shift"

  [shell]
  args = ["--cd ~"]
  program = 'C:\Windows\System32\wsl.exe'
  ```

#### Setting up Dev Tools

1. Create a [fine-grained personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token) in Github

1. Open an Alacritty terminal (which should launch WSL)

1. Add the following to `~/.bashrc`, then run `sudo su` followed by `cd ~`:

    ```sh
    # Always log in as root
    cd /
    sudo su
    ```

1. Once you're logged in as root, add the following to `~/.bashrc` along with any other API keys, special commands, etc. 

    ```sh
    ##################
    # Custom Configs #
    ##################

    # Start a Nix shell with dev tools
    nixdev() {
      sudo apt update -y && sudo apt upgrade -y && sudo apt autoremove -y
      nix \
        --extra-experimental-features 'flakes' \
        --extra-experimental-features 'nix-command' \
        develop \
        --show-trace \
        --no-write-lock-file \
        'git+https://github.com/chris-de-leon/dotfiles'
    }
 
    # Github
    export GITHUB_UNAME="your github username"
    export GITHUB_PAT="your github personal access token"
    if [ ! -f ~/.git-credentials ]; then
      echo "https://$GITHUB_UNAME:$GITHUB_PAT@github.com" >~/.git-credentials
    fi

    # If starship is available, use it to make the prompt pretty
    if command -v starship &>/dev/null; then
      eval "$(starship init bash)"
    fi
    ```

1. Make sure `~/.gitconfig` is configured the way you like:

    ```sh
    # This is Git's per-user configuration file.
    [user]
        name = <your name>
        email = <your email>

    [core]
        editor = vim

    [credential]
        helper = store
    ```

1. Install Nix [v2.23.1 or later](https://nixos.org/download/):

    ```sh
    sh <(curl -L https://nixos.org/nix/install) --daemon
    ```

    You can also use the [Determinate Nix Installer](https://zero-to-nix.com/start/install):

    ```sh
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    ```

    Which comes with an [uninstall script](https://zero-to-nix.com/start/uninstall):

    ```sh
    /nix/nix-installer uninstall
    ```

1. Close the current terminal

1. Open a new Alacritty terminal, log in, and run `cd ~`

1. To make sure all packages are up to date and enter a fully configured dev shell, you can run:

    ```sh
    nixdev
    ```

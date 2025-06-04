# Alacritty

## Linux

1. Download a [Nerd Font](https://www.nerdfonts.com/) of your choice (CaskaydiaCove is recommended)
1. Unzip the font
1. Copy the font files to `~/.fonts`
1. Run `fc-cache -fv` to update Ubuntu's font cache
1. Create an Alacritty config file at `~/.config/alacritty/alacritty.toml` with the following values (the font family should be modified accordingly if you chose a font other than CaskaydiaCove):

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
```

## Windows

1. Use the `.msi` installer on the [Alacritty releases](https://github.com/alacritty/alacritty/releases) page to install alacritty
1. Download a [Nerd Font](https://www.nerdfonts.com/) of your choice
1. Add the Nerd Font to your font library
1. Create an Alacritty config file at `Users/<your user>/AppData/Roaming/alacritty/alacritty.toml` with the following values (the font family should be modified accordingly if you chose a font other than CaskaydiaCove):

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
program = 'C:\Windows\System32\cmd.exe'
```

## Windows WSL

1. Use the `.msi` installer on the [Alacritty releases](https://github.com/alacritty/alacritty/releases) page to install alacritty
1. Download a [Nerd Font](https://www.nerdfonts.com/) of your choice
1. Add the Nerd Font to your font library
1. Create an Alacritty config file at `Users/<your user>/AppData/Roaming/alacritty/alacritty.toml` with the following values (the font family should be modified accordingly if you chose a font other than CaskaydiaCove):

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

## MacOS

1. Install [homebrew](https://brew.sh/)
1. Install bash: `brew install bash`
1. Use the `.dmg` installer on the [Alacritty releases](https://github.com/alacritty/alacritty/releases) page to install alacritty
1. Download a [Nerd Font](https://www.nerdfonts.com/) of your choice (CaskaydiaCove is recommended)
1. Import the fonts into the Font Book
1. Create an Alacritty config file at `~/.config/alacritty/alacritty.toml` with the following values (the font family should be modified accordingly if you chose a font other than CaskaydiaCove):

```toml
[window]
option_as_alt = "Both"

[font]
size = 12.0 # modify as needed

[font.bold]
family = "CaskaydiaCove NF"
style = "Bold"

[font.bold_italic]
family = "CaskaydiaCove NF"
style = "Bold Italic"

[font.italic]
family = "CaskaydiaCove NF"
style = "Italic"

[font.normal]
family = "CaskaydiaCove NF"
style = "Regular"

[terminal]

[terminal.shell]
args = ["--login"]
program = "/opt/homebrew/bin/bash"
```

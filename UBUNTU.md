# Ubuntu 24.04 settings

## Neovim, Alacritty

- Clone source under `~/source/`
- Build
- Copy executables to /usr/local/bin

### :checkhealth

## XKB

```
# Overwrite XKBOPTIONS
$ sudo sed -i 's/^XKBOPTIONS=.*/XKBOPTIONS="ctrl:nocaps"/' /etc/default/keyboard

# Restart console-setup
$ sudo systemctl restart console-setup

# Log out then log in again
```

## XMonad

GHCup

- https://www.haskell.org/ghcup/install/

xterm, dmenu
- sudo apt install xterm dmenu

gnome-flashback

- sudo apt install gnome-flashback
- seems to be unnecessary

make `/usr/share/xsessions/xmonad.desktop` file
```
[Desktop Entry]
Encoding=UTF-8
Name=XMonad
Comment=Lightweight tiling window manager
Exec=xmonad
Icon=xmonad.png
Type=XSession
```

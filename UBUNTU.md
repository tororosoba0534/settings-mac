# Ubuntu 24.04 settings

## Neovim, Alacritty

- Clone source under `~/source/`
- Build
- Copy executables to /usr/local/bin

### :checkhealth

## xremap

- Clone source under `~/source/`
- Build
- Copy executables to `/usr/local/bin`
- Enable executable to be executed without `sudo`
  - https://github.com/xremap/xremap?tab=readme-ov-file#running-xremap-without-sudo
  - sudo gpasswd -a YOUR_USER input
  - echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/input.rules


TODO: Don't place executable in `$PATH` and call proper binary suitable to the current window system.


## XKB

```
# Overwrite XKBOPTIONS
$ sudo sed -i 's/^XKBOPTIONS=.*/XKBOPTIONS="ctrl:nocaps"/' /etc/default/keyboard

# Restart console-setup
$ sudo systemctl restart console-setup

# Log out then log in again
```

## hoogle

cabal install hoogle

hoogle generate

hoogle server

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

## AutoKey

sudo apt install autokey-gtk

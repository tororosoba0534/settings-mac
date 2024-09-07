# My portable settings

## iTerm2

### mouse

- Profiles -> Terminal -> check "Enable mouse reporting" -> check "Report mouse wheel events" and "Report mouse clicks & drags"
- Pointer -> General -> check "⌥-Click moves cursor"
  - enables selecting text

### transparency

- Profiles -> Window -> Transparency -> 40 %

### hotkey

- Keys -> Hotkey -> check "Show/hide all windows wih a system-wide hotkey" -> Hotkey: ⌥Space

## Chrome extensions

### Vimium

#### Custom key mappings

```
map F LinkHints.activateModeToOpenInNewForegroundTab
map <c-F> LinkHints.activateModeToOpenInNewTab
map <a-c-F> LinkHints.activateModeToOpen
map <c-d> scrollFullPageDown
map <c-u> scrollFullPageUp
map h previousTab
map l nextTab
map J moveTabLeft
map K moveTabRight
map T duplicateTab
```

## zathura (pdf viewer)

- https://github.com/zegervdv/homebrew-zathura
- Using HEAD of zathura & girara
- plugin: zathura-pdf-poppler

## Rectangle (window resizer)

- https://github.com/rxhanson/Rectangle

### keybinds

- cmd-shift-h (left half)
- cmd-shift-l (right half)
- cmd-shift-j (almost maximize)
- cmd-shift-k (maximize)

## HOW TO LINK FILES

### in `~/settings-mac/partial-links/` dir:

`ln -s ~/settings-mac/partial-links/.config/karabiner/assets/complex_modifications ~/.config/karabiner/assets/complex_modifications`

### on the root of the project:

`ln -s ~/settings-mac/.zshrc ~/.zshrc`

### in `~/settings-mac/.config/` dir:

`ln -s ~/settings-mac/.config/nvim ~/.config/nvim`

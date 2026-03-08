# Kanata Keybindings

Space Cadet keys + Layer-based navigation, accents, and window management.

## Primary Remappings

| Physical Key | Tap | Hold | Description |
| ------------ | --- | ---- | ----------- |
| ⇪ Caps Lock | ⎋ | ⎈ | Escape or Control |
| ⭾ Tab | ⭾ | Hyper | ⎈⌥⌘⇧ (app launchers) |
| `=` | `=` | Window | ⎈⌥ layer (WM control) |
| ‹⇧ Left Shift | `(` | ⇧ | Parenthesis or Shift |
| ⇧› Right Shift | `)` | ⇧ | Parenthesis or Shift |
| ‹⎈ Left Ctrl | `{` | ⎈ | Brace or Control |
| ␣ Space | ␣ | Nav | Navigation layer (arrows) |
| ˋ Grave | ˋ | Accent | Accented characters |

## Navigation Layer (Hold ␣)

| Key | Action |
| --- | ------ |
| `h` | ◀ Left |
| `j` | ▼ Down |
| `k` | ▲ Up |
| `l` | ▶ Right |
| `y` | ⇤ Home |
| `u` | ⇟ Page Down |
| `i` | ⇞ Page Up |
| `o` | ⇥ End |

## Window Layer (Hold `=`)

Sends `Ctrl+Alt+key`. Used by AeroSpace window manager.

| Key | Action |
| --- | ------ |
| `hjkl` | Focus direction (AeroSpace) |
| `1-9` | Switch workspace (AeroSpace) |
| `q` | Close window |
| `Space` | Toggle floating |
| `Tab` | Last workspace |
| `s` | Session manager |
| `f` | Toggle fullscreen |
| `Enter` | Launch terminal |

### Separation from Terminal Multiplexers

| Target | Modifier | Example |
| ------ | -------- | ------- |
| AeroSpace (GUI WM) | `Ctrl+Alt` via `=` layer | `=+1` → workspace 1 |
| tmux/zellij (terminal) | `Alt` (direct) | `Alt+1` → tmux window/zellij tab |

Terminal multiplexers (tmux-tilish, zellij) use plain `Alt` bindings directly. The `=` layer is for AeroSpace window management.

## Accent Layer (Hold Grave)

| Key | Output | Key | Output |
| --- | ------ | --- | ------ |
| `a` | á | `1` | ¡ |
| `e` | é | `2` | ² |
| `i` | í | `3` | ³ |
| `o` | ó | `9` | ø |
| `u` | ú | `0` | å |
| `n` | ñ | `;` | æ |
| `s` | ß | `'` | ü |
| `c` | ç | `q` | ¿ |
| `w` | œ | `m` | µ |

## Platform-Specific Notes

| Platform | Config File | Notes |
| -------- | ----------- | ----- |
| macOS | `darwin.kbd` | Both `grv` and `nubs` mapped for multi-keyboard support |
| Linux | `laptop.kbd` | Uses `linux-dev` for device path |
| Windows | `windows.kbd` | No device path needed |

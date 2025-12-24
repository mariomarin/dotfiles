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

Sends `Ctrl+Alt+key`. Used by tmux-tilish and zellij (not AeroSpace).

| Key | Action |
| --- | ------ |
| `hjkl` | Navigate panes |
| `1-9` | Switch tab/window |
| `q` | Close pane |
| `Space` | Cycle layouts |
| `Tab` | Last tab |
| `s` | Session manager |
| `f` | Toggle floating |
| `-` / `\` | Split horizontal/vertical |
| `"` | New pane |

### Separation from AeroSpace

| Target | Modifier | Example |
| ------ | -------- | ------- |
| AeroSpace (GUI WM) | `Alt` (direct) | `Alt+1` → workspace 1 |
| tmux/zellij (terminal) | `Ctrl+Alt` via `=` layer | `=+1` → tab 1 |

AeroSpace uses plain `Alt` bindings directly. The `=` layer is only for terminal multiplexers.

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

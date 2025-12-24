# AeroSpace Keybindings

i3/LeftWM-style keybindings using Alt modifier (like Super on Linux).

## Navigation

| Binding | Action |
| ------- | ------ |
| `Alt+hjkl` | Focus direction |
| `Alt+Shift+hjkl` | Move window |
| `Alt+1-9` | Switch workspace |
| `Alt+Shift+1-9` | Move to workspace |

## Window Actions

| Binding | Action |
| ------- | ------ |
| `Alt+f` | Fullscreen |
| `Alt+Shift+q` | Close |
| `Alt+Enter` | Terminal (Alacritty) |
| `Alt+Space` | Toggle floating |
| `Alt+Tab` | Last workspace |
| `Alt+e` | Cycle layouts (h_tiles → v_tiles → accordion) |
| `Alt+r` | Resize mode |
| `Alt+w` | Swap workspaces between monitors |

## Monitor Navigation

| Binding | Action |
| ------- | ------ |
| `Alt+,` | Focus previous monitor |
| `Alt+.` | Focus next monitor |
| `Alt+Shift+,` | Move to previous monitor |
| `Alt+Shift+.` | Move to next monitor |

## Resize Mode (`Alt+r`)

| Key | Action |
| --- | ------ |
| `hjkl` | Resize in direction |
| `-/=` | Shrink/grow smart |
| `Esc/Enter` | Exit resize mode |

## Separation from tmux-tilish

| Target | Modifier | Example |
| ------ | -------- | ------- |
| AeroSpace (GUI WM) | `Alt` | `Alt+1` → workspace 1 |
| tmux-tilish (terminal) | `Ctrl+Alt` via Kanata `=` layer | `=+1` → tmux window 1 |

This keeps window management (`Alt`) separate from terminal multiplexer (`Ctrl+Alt`).

# AeroSpace Keybindings

i3/LeftWM-style keybindings using Ctrl+Alt modifier (via Kanata `=` layer).

## Navigation

| Binding | Action |
| ------- | ------ |
| `Ctrl+Alt+hjkl` | Focus direction |
| `Ctrl+Alt+Shift+hjkl` | Move window |
| `Ctrl+Alt+1-9` | Switch workspace |
| `Ctrl+Alt+Shift+1-9` | Move to workspace |

## Window Actions

| Binding | Action |
| ------- | ------ |
| `Ctrl+Alt+f` | Fullscreen |
| `Ctrl+Alt+Shift+q` | Close |
| `Ctrl+Alt+Enter` | Terminal (Alacritty) |
| `Ctrl+Alt+Space` | Toggle floating |
| `Ctrl+Alt+Tab` | Last workspace |
| `Ctrl+Alt+e` | Cycle layouts (h_tiles → v_tiles → accordion) |
| `Ctrl+Alt+r` | Resize mode |
| `Ctrl+Alt+w` | Swap workspaces between monitors |

## Monitor Navigation

| Binding | Action |
| ------- | ------ |
| `Ctrl+Alt+,` | Focus previous monitor |
| `Ctrl+Alt+.` | Focus next monitor |
| `Ctrl+Alt+Shift+,` | Move to previous monitor |
| `Ctrl+Alt+Shift+.` | Move to next monitor |

## Resize Mode (`Ctrl+Alt+r`)

| Key | Action |
| --- | ------ |
| `hjkl` | Resize in direction |
| `-/=` | Shrink/grow smart |
| `Esc/Enter` | Exit resize mode |

## Separation from tmux-tilish

| Target | Modifier | Example |
| ------ | -------- | ------- |
| AeroSpace (GUI WM) | `Ctrl+Alt` via Kanata `=` layer | `=+1` → workspace 1 |
| tmux-tilish (terminal) | `Alt` | `Alt+1` → tmux window 1 |

This keeps window management (`Ctrl+Alt`) separate from terminal multiplexer (`Alt`).

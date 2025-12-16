# AeroSpace Keybindings

i3-style keybindings via window mode (`=`-hold via kanata).

## Window Mode (`=`-hold)

| Binding | Action |
| ------- | ------ |
| `=+hjkl` | Focus direction |
| `=+Shift+hjkl` | Move window |
| `=+1-9` | Switch workspace |
| `=+Shift+1-9` | Move to workspace |
| `=+f` | Fullscreen |
| `=+q` | Close |
| `=+t` / `=+Enter` | Terminal |
| `=+r` | Resize mode |
| `=+;` | Service mode |
| `=+Space` | Toggle floating |
| `=+Tab` | Last workspace |
| `=+e` | Cycle layouts (h_tiles → v_tiles → accordion) |

## App Launchers (Hyper = Tab-hold)

| Binding | App |
| ------- | --- |
| `Hyper+t` | Alacritty |
| `Hyper+b` | Firefox |
| `Hyper+m` | Spotify |
| `Hyper+o` | Obsidian |
| `Hyper+s` | Slack |

## Notes

- All WM bindings use `Ctrl+Alt` prefix (sent by kanata's `=`-hold)
- No plain `Alt+*` bindings to avoid tmux-tilish conflicts

## Window Mode + Cmd for tmux

Adding Cmd to window mode keys triggers tmux-tilish instead of AeroSpace:

| Key | Target |
| --- | ------ |
| `=+1` | AeroSpace workspace 1 |
| `=+Cmd+1` | tmux window 1 |
| `=+Tab` | AeroSpace last workspace |
| `=+Cmd+Tab` | tmux last window |

See [kanata KEYBINDINGS.md](../kanata/KEYBINDINGS.md) for details.

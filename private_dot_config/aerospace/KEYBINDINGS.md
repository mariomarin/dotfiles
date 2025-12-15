# AeroSpace Keybindings

i3-style keybindings via window mode (`=`-hold).

On macOS, `=`-hold acts like `Super` on Linux. Shift passes through for move operations.

## Window Mode (`=`-hold via kanata)

| Binding         | Action              |
| --------------- | ------------------- |
| `=+hjkl`        | Focus               |
| `=+Shift+hjkl`  | Move window         |
| `=+1-9`         | Workspace           |
| `=+Shift+1-9`   | Move to workspace   |
| `=+f`           | Fullscreen          |
| `=+t`           | Float/tile toggle   |
| `=+q`           | Close               |
| `=+Return`      | Terminal            |
| `=+r`           | Resize mode         |
| `=+;`           | Service mode        |

## App Launchers (Hyper = Tab-hold)

| Binding        | App       |
| -------------- | --------- |
| `Hyper+Return` | Alacritty |
| `Hyper+b`      | Firefox   |
| `Hyper+m`      | Spotify   |
| `Hyper+o`      | Obsidian  |
| `Hyper+s`      | Slack     |

## Alt (non-conflicting only)

| Binding   | Action            |
| --------- | ----------------- |
| `Alt+f`   | Fullscreen        |
| `Alt+t`   | Float/tile toggle |
| `Alt+Tab` | Last workspace    |
| `Alt+r`   | Resize mode       |

## Modes

### Resize Mode

`hjkl` to resize, `-/=` smart resize, `Esc/Enter` exit.

### Service Mode

`Esc` reload, `r` flatten, `f` float, `Backspace` close others.

## Summary

```text
=-hold = window management (no tmux conflict)
Tab-hold = Hyper (app launchers)
Alt = non-conflicting shortcuts only
```

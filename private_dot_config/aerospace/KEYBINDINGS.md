# AeroSpace Keybindings

Dual modifier approach: **Hyper** (Tab-hold) avoids tmux conflict, **Alt** works outside tmux.

## Navigation

| Hyper        | Alt             | Description              |
| ------------ | --------------- | ------------------------ |
| `Hyper+hjkl` | `Alt+hjkl`      | Focus left/down/up/right |
| -            | `Alt+Arrow`     | Focus (arrow keys)       |

## Move Windows

| Hyper | Alt               | Description              |
| ----- | ----------------- | ------------------------ |
| -     | `Alt+Shift+hjkl`  | Move window              |
| -     | `Alt+Shift+Arrow` | Move window (arrows)     |

## Workspaces

| Hyper       | Alt               | Description              |
| ----------- | ----------------- | ------------------------ |
| `Hyper+1-9` | `Alt+1-9`         | Switch to workspace      |
| -           | `Alt+Shift+1-9`   | Move window to workspace |
| -           | `Alt+Ctrl+h/l`    | Prev/next workspace      |
| -           | `Alt+Tab`         | Last workspace           |
| -           | `Alt+Shift+,/.`   | Move window to prev/next |

## Layouts

| Hyper     | Alt           | Description            |
| --------- | ------------- | ---------------------- |
| `Hyper+f` | `Alt+f`       | Toggle fullscreen      |
| `Hyper+t` | `Alt+t`       | Toggle floating/tiling |
| `Hyper+/` | `Alt+/`       | Cycle tile layouts     |
| -         | `Alt+Ctrl+j`  | Tiles layout           |
| -         | `Alt+Ctrl+k`  | Accordion layout       |

## Window Management

| Hyper     | Alt             | Description    |
| --------- | --------------- | -------------- |
| `Hyper+q` | `Alt+Shift+q`   | Close window   |
| -         | `Alt+Shift+Ret` | Open Alacritty |

## App Launchers (Hyper only)

| Keybinding     | App       | Mnemonic     |
| -------------- | --------- | ------------ |
| `Hyper+Return` | Alacritty | Terminal     |
| `Hyper+b`      | Firefox   | **B**rowser  |
| `Hyper+m`      | Spotify   | **M**usic    |
| `Hyper+o`      | Obsidian  | **O**bsidian |
| `Hyper+s`      | Slack     | **S**lack    |

## Modes

| Hyper     | Alt           | Description        |
| --------- | ------------- | ------------------ |
| `Hyper+r` | `Alt+r`       | Enter resize mode  |
| `Hyper+;` | `Alt+Shift+;` | Enter service mode |

### Resize Mode

`hjkl` or arrows to resize, `-/=` for smart resize, `Esc/Enter` to exit.

### Service Mode

`Esc` reload, `r` flatten, `f` float toggle, `Backspace` close others.

## Auto-Float Apps

Finder, System Preferences, Calculator, Preview

## Usage Notes

- **In tmux**: Use Hyper (Tab-hold) - Alt goes to tmux-tilish
- **Outside tmux**: Either works, Alt is faster (no Tab-hold)

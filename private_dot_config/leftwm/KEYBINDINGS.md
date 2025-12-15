# LeftWM Keybindings Reference

**Mod key**: Super/Windows key (Mod4)
**Hyper**: Tab-hold via kanata = Ctrl+Alt+Super+Shift (cross-platform with macOS)

## App Launchers (Cross-Platform)

Same mnemonics work with both Super and Hyper (Tab-hold).

| Super              | Hyper          | App       | Mnemonic     |
| ------------------ | -------------- | --------- | ------------ |
| `Mod+t`            | `Hyper+t`      | Alacritty | **T**erminal |
| `Mod+b`            | `Hyper+b`      | Firefox   | **B**rowser  |
| `Mod+m`            | `Hyper+m`      | Spotify   | **M**usic    |
| `Mod+o`            | `Hyper+o`      | Obsidian  | **O**bsidian |
| `Mod+s`            | `Hyper+s`      | Slack     | **S**lack    |
| `Mod+Space`        | -              | Rofi      | Launcher     |
| `Mod+Shift+Return` | `Hyper+Return` | Alacritty | Alt terminal |
| `Mod+y`            | -              | ytfzf     | YouTube      |
| `Mod+p`            | -              | Power     | Shutdown     |

## Window Navigation

| Super             | Hyper     | Description           |
| ----------------- | --------- | --------------------- |
| `Mod+j` / `Mod+↓` | `Hyper+j` | Focus next window     |
| `Mod+k` / `Mod+↑` | `Hyper+k` | Focus previous window |
| `Mod+h` / `Mod+←` | `Hyper+h` | Previous workspace    |
| `Mod+l` / `Mod+→` | `Hyper+l` | Next workspace        |
| `Mod+f`           | `Hyper+f` | Toggle fullscreen     |
| `Mod+Shift+q`     | `Hyper+q` | Close window          |

## Workspace/Tag Navigation

| Keybinding      | Hyper       | Description              |
| --------------- | ----------- | ------------------------ |
| `Mod+1-9`       | `Hyper+1-9` | Switch to workspace 1-9  |
| `Mod+Shift+1-9` | -           | Move window to workspace |
| `Mod+Tab`       | -           | Swap to last workspace   |
| `Mod+w`         | -           | Swap to last workspace   |
| `Mod+Shift+w`   | -           | Move window to last ws   |
| `Mod+Shift+,`   | -           | Move window to prev ws   |
| `Mod+Shift+.`   | -           | Move window to next ws   |

## Window Movement

| Keybinding                    | Description        |
| ----------------------------- | ------------------ |
| `Mod+Enter`                   | Move window to top |
| `Mod+Shift+j` / `Mod+Shift+↓` | Move window down   |
| `Mod+Shift+k` / `Mod+Shift+↑` | Move window up     |

## Layout Management

| Keybinding                  | Description         |
| --------------------------- | ------------------- |
| `Mod+Ctrl+j` / `Mod+Ctrl+↓` | Previous layout     |
| `Mod+Ctrl+k` / `Mod+Ctrl+↑` | Next layout         |
| `Mod+Shift+→`               | Increase main width |
| `Mod+Shift+←`               | Decrease main width |

## Screenshots

| Keybinding     | Description   |
| -------------- | ------------- |
| `Print Screen` | Region        |
| `Shift+Print`  | Active window |
| `Ctrl+Print`   | Full monitor  |

Saved to `~/Pictures/screenshots/`.

## System Control

| Keybinding    | Description  |
| ------------- | ------------ |
| `Mod+Shift+r` | Reload       |
| `Mod+Shift+x` | Exit/logout  |
| `Mod+Shift+l` | Lock screen  |

## Media Keys

Volume Up/Down, Mute, Mic Mute, Brightness Up/Down.

## Available Layouts

Cycle with `Mod+Ctrl+j/k`:

- MainAndVertStack, MainAndHorizontalStack, MainAndDeck
- GridHorizontal, EvenHorizontal, EvenVertical, Fibonacci
- LeftMain, CenterMain, CenterMainBalanced, CenterMainFluid
- Monocle, RightWiderLeftStack, LeftWiderRightStack

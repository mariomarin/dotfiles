# LeftWM Keybindings Reference

This document lists all configured keybindings for the LeftWM window manager.

**Note**: Mod key = Super/Windows key (Mod4)

## Window Management

| Keybinding | Description |
| ---------- | ----------- |
| `Mod + Shift + q` | Close the current window |
| `Mod + f` | Toggle fullscreen for focused window |
| `Mod + Enter` | Move selected window to the top of the stack |
| `Mod + j` / `Mod + ↓` | Focus next window (down) |
| `Mod + k` / `Mod + ↑` | Focus previous window (up) |
| `Mod + Shift + j` / `Mod + Shift + ↓` | Move window down in stack |
| `Mod + Shift + k` / `Mod + Shift + ↑` | Move window up in stack |

## Workspace/Tag Navigation

| Keybinding | Description |
| ---------- | ----------- |
| `Mod + 1-9` | Switch to workspace/tag 1-9 |
| `Mod + Shift + 1-9` | Move focused window to workspace/tag 1-9 |
| `Mod + h` / `Mod + ←` | Focus previous workspace |
| `Mod + l` / `Mod + →` | Focus next workspace |
| `Mod + Alt + Tab` | Jump to next workspace |
| `Mod + Alt + Shift + Tab` | Jump to previous workspace |
| `Mod + Ctrl + Tab` | Swap to last visited workspace ¹ |
| `Mod + w` | Swap to last visited workspace ¹ |
| `Mod + Shift + w` | Move window to last visited workspace |

¹ *Duplicate binding - both keys perform the same action*

## Layout Management

| Keybinding | Description |
| ---------- | ----------- |
| `Mod + Ctrl + j` / `Mod + Ctrl + ↓` | Switch to previous layout ² |
| `Mod + Ctrl + k` / `Mod + Ctrl + ↑` | Switch to next layout ² |
| `Mod + Shift + →` | Increase main window width (+3%) |
| `Mod + Shift + ←` | Decrease main window width (-3%) |

² *Duplicate binding - both key combinations perform the same action*

## Applications

| Keybinding | Description |
| ---------- | ----------- |
| `Mod + Space` | Launch application menu (Rofi) |
| `Mod + Shift + Return` | Open terminal (Alacritty) |
| `Mod + y` | YouTube search (ytfzf) |
| `Mod + p` | Power menu (shutdown/reboot/logout) |

## Screenshots

| Keybinding | Description |
| ---------- | ----------- |
| `Print Screen` | Screenshot a region (select with mouse) |
| `Shift + Print Screen` | Screenshot active window |
| `Ctrl + Print Screen` | Screenshot full monitor |

Screenshots are saved to `~/Pictures/screenshots/` with descriptive filenames.

## System Control

| Keybinding | Description |
| ---------- | ----------- |
| `Mod + Shift + r` | Reload LeftWM configuration (soft reload) |
| `Mod + Shift + x` | Exit LeftWM (logout) |
| `Mod + Ctrl + l` | Lock screen (slock) ³ |
| `Mod + Shift + l` | Lock screen (xfce4-screensaver) ³ |

³ *Two different lock screen implementations available*

## Media & Hardware Controls

| Keybinding | Description |
| ---------- | ----------- |
| `Volume Up` | Increase volume by 5% |
| `Volume Down` | Decrease volume by 5% |
| `Mute` | Toggle audio mute |
| `Mic Mute` | Toggle microphone mute |
| `Brightness Up` | Increase screen brightness by 5% |
| `Brightness Down` | Decrease screen brightness by 5% |

## Available Layouts

LeftWM cycles through these layouts using `Mod + Ctrl + j/k`:

1. MainAndVertStack (default)
2. MainAndHorizontalStack
3. MainAndDeck
4. GridHorizontal
5. EvenHorizontal
6. EvenVertical
7. Fibonacci
8. LeftMain
9. CenterMain
10. CenterMainBalanced
11. CenterMainFluid
12. Monocle
13. RightWiderLeftStack
14. LeftWiderRightStack

## Workspace Icons

Workspaces are labeled with Font Awesome icons:

1. 󰌾 Terminal/Development
2. 󰊯 Web Browser
3. 󰈸 Code Editor
4. 󰋅 Books/Documentation
5. 󰋆 Graphics/Design
6. 󰀁 Music
7. 󰇮 Email
8. 󰈀 Notes/Writing
9. 󰊻 Gaming

## Configuration Files

- Main config: `~/.config/leftwm/config.ron`
- Theme config: `~/.config/leftwm/themes/custom/theme.ron`
- Theme scripts: `~/.config/leftwm/themes/custom/up` and `down`

## Tips

- Hold `Mod` and use vim keys (h,j,k,l) for navigation
- Arrow keys provide alternative bindings for most navigation
- The Tab-based workspace navigation follows familiar Alt-Tab patterns
- All screenshots include timestamps in filenames for easy organization

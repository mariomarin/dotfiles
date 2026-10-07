# Keybindings Reference

Single source of truth for keybindings across the stack. Check the conflict guide before adding a binding, and update the component section when you change one.

## Quick Conflict Guide

| Key Space | Owner | Notes |
| --------- | ----- | ----- |
| `M-h/j/k/l` | tmux-tilish + tmux.nvim | Pane/split navigation, vim-aware |
| `M-=/-/+/_` | tmux-tilish + tmux.nvim | Pane/split resizing, vim-aware |
| `M-1` to `M-9` | tmux-tilish | Switch windows |
| `M-Tab` | tmux-tilish | Last active window |
| `M-Enter` | tmux-tilish | New pane |
| `M-b` | tmux-harpoon | Fuzzy-jump sessions |
| `M-a` | tmux-harpoon | Jump to slot 2 |
| `C-S-a` | tmux-harpoon | Jump to slot 1 |
| `C-S-h` | tmux-harpoon | Add session |
| `C-a` | tmux prefix | — |
| `Ctrl+Alt+…` | LeftWM / Hammerspoon | Sent by the Kanata `=` layer |
| `Super+…` | LeftWM | Window manager (Linux only) |
| `Hyper+…` | Hammerspoon | App launchers (macOS only) |
| `<Space>` | Neovim leader | — |

## Layer Overview

```text
Physical keys
  └── Kanata (Caps→Esc/Ctrl, Space or RAlt→Nav, = →Ctrl+Alt window layer)
        └── Terminal / tmux (prefix=C-a, tilish M-keys, harpoon, fingers)
              └── Neovim (leader=Space, harpoon2, flash)
LeftWM / Hammerspoon (Super, Ctrl+Alt, Hyper — window manager level, bypass tmux)
```

## Kanata

Configs: `darwin.kbd` (macOS), `laptop.kbd` / `windows.kbd` (standalone Linux / Windows), `core.kbd` (NixOS service).

| Physical key | Tap | Hold | Platforms |
| ------------ | --- | ---- | --------- |
| Caps Lock | Esc | Ctrl | All |
| Tab | Tab | Hyper (Ctrl+Alt+Cmd, +Shift on macOS/NixOS) | All |
| Left / Right Shift | `(` / `)` | Shift | All |
| Left Ctrl | `{` | Ctrl | macOS, laptop, Windows |
| Space | Space | Nav layer | macOS, laptop, Windows |
| Left Alt | `<` | Alt | NixOS |
| Right Alt | `>` | Nav layer | NixOS |
| `=` | `=` | Window layer | macOS, NixOS |
| `` ` `` (and `§` on MacBook) | `` ` `` | Accent layer | macOS, laptop, Windows |

**Nav layer**: `h/j/k/l` arrows, `y/u/i/o` Home / PgDn / PgUp / End.

**Window layer**: every key is sent as `Ctrl+Alt+key` (Shift passes through), handled by LeftWM or Hammerspoon below.

**Accent layer**:

| Key | Output | Key | Output | Key | Output |
| --- | ------ | --- | ------ | --- | ------ |
| `a` | á | `n` | ñ | `1` | ¡ |
| `e` | é | `s` | ß | `2` | ² |
| `i` | í | `c` | ç | `3` | ³ |
| `o` | ó | `w` | œ | `9` | ø |
| `u` | ú | `q` | ¿ | `0` | å |
| `'` | ü | `;` | æ | `m` | µ |

## Tmux

Prefix: `C-a`. Defaults not listed here are standard tmux.

### Sessions and windows

| Key | Action |
| --- | ------ |
| `prefix T` | sesh session picker |
| `prefix L` | Last session (sesh, then tmux, then picker) |
| `prefix C-c` | New session |
| `prefix C-f` | Find session |
| `prefix w` | Window tree |
| `prefix Tab` / `M-Tab` | Last window |
| `prefix x` | Kill pane (no prompt) |
| `prefix C-g` | Split and run navi |
| `prefix g` | GitHub PR dashboard (gh-dash) |
| `prefix b` | Toggle status bar |
| `prefix r` | Reload config |
| `prefix C-s` / `prefix C-r` | Save / restore sessions (tmux-resurrect) |

### Copy, hints and buffers

| Key | Action |
| --- | ------ |
| `prefix Space` | Hints (tmux-fingers): `hint` copies, `Shift+hint` opens with `peek`, `Ctrl+hint` pastes, `Tab` multi-select |
| `prefix j` | Jump (tmux-fingers): move the copy-mode cursor to a hint |
| `prefix ?` | Search scrollback with fzf (tmux-fuzzback) |
| `prefix /` | Copy mode, search forward |
| `prefix y` / `prefix Y` | Copy command line / pane directory (tmux-yank) |
| `prefix p` / `prefix P` / `prefix B` | Paste / choose / list buffers |

Copy mode (vi): `v` select, `V` line, `C-v` rectangle, `o` other end, `C-c` clear, `H`/`L` line start/end, `%` matching bracket, `y`/`Enter` copy (tmux-yank).

### tmux-tilish (no prefix)

| Key | Action |
| --- | ------ |
| `M-h/j/k/l` | Focus pane (vim-aware) |
| `M-H/J/K/L` | Move pane |
| `M-=` / `M--` / `M-+` / `M-_` | Resize left / right / down / up (vim-aware) |
| `M-1`…`M-9`, `M-0` | Switch window |
| `M-!`…`M-(` | Move pane to window 1–9 |
| `M-Enter` | New pane |
| `M-z` | Zoom |
| `M-Q` | Close pane |
| `M-s` / `M-S` / `M-v` / `M-V` / `M-t` | Layouts: main-h / even-v / main-v / even-h / tiled |
| `M-r` | Refresh layout |
| `M-n` | Rename window |
| `M-d` | Command launcher (dmenu) |
| `M-E` / `M-C` | Detach / reload config |

### tmux-harpoon

| Key | Action |
| --- | ------ |
| `M-b` | Fuzzy-jump to a saved session/pane |
| `C-S-h` | Add current session |
| `C-S-a` / `M-a` | Jump to slot 1 / 2 |

## Neovim

Leader: `<Space>`. LazyVim defaults apply; see the [LazyVim keymaps](https://www.lazyvim.org/keymaps). Custom and extra bindings:

| Key | Action |
| --- | ------ |
| `;` | Command mode |
| `jk` | Exit insert mode |
| `<C-s>` | Save (normal, insert, visual) |
| `s` / `S` | Flash jump / Flash treesitter (LazyVim default) |
| `M-h/j/k/l`, `M-=/-/+/_` | Navigate / resize splits and tmux panes (tmux.nvim) |
| `<leader>wm`, `<C-w>o` | Maximize / restore window |
| `<leader>H` / `<leader>h` / `<leader>1-9` | Harpoon: add file / menu / jump to mark |
| `<leader>gs` / `<leader>gb` / `<leader>gd` | Fugitive: status / blame / diff |
| `<leader>cc` / `<leader>c.` / `<leader>cr` | Claude Code: toggle / continue / reload modified files |
| `<leader>o…` | Obsidian: `n` new, `o` open, `s` search, `q` switch, `t`/`y`/`d` daily notes, `b` backlinks, `l` follow link, `g` tags |

## LeftWM

Mod: `Super`. Most actions are mirrored on `Ctrl+Alt` (sent by the Kanata `=` layer).

| Key | Action |
| --- | ------ |
| `Super+h` / `Super+l` | Previous / next workspace |
| `Super+j` / `Super+k` | Focus window down / up |
| `Super+Shift+j` / `Super+Shift+k` | Move window down / up |
| `Super+Shift+,` / `Super+Shift+.` | Move window to previous / next workspace |
| `Super+1-9` / `Super+Shift+1-9` | Go to / move window to tag |
| `Super+Tab`, `Super+w` | Swap tags between workspaces |
| `Super+Shift+w` | Move to last workspace |
| `Super+Return` | Move window to top of stack |
| `Super+f` | Fullscreen |
| `Super+Shift+q` | Close window |
| `Super+Ctrl+k` / `Super+Ctrl+j` | Next / previous layout |
| `Super+Shift+Left/Right` | Shrink / grow main width |
| `Super+Space` | Rofi launcher |
| `Super+Shift+Return`, `Super+t` | Terminal |
| `Super+b/m/o/s/y/p` | Firefox / Spotify / Obsidian / Slack / ytfzf / power menu |
| `Super+Shift+l` | Lock screen |
| `Super+Shift+r` / `Super+Shift+x` | Reload / exit |

### Hammerspoon (macOS)

Mirrors LeftWM through the Kanata `=` layer (`Ctrl+Alt+key`):

| Key | Action |
| --- | ------ |
| `= 1-9` / `= Shift+1-9` | Switch to / move window to desktop |
| `= h` / `= l` | Previous / next space |
| `= j` / `= k` | Focus window below / above |
| `= w` | Swap windows between monitors |
| `= Shift+,` / `= Shift+.` | Move window to previous / next monitor |
| `= i` | Show desktop info (debug) |

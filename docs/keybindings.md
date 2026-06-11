# Keybindings Reference

Unified index for all keybindings across the stack. Check here first when adding new bindings to avoid conflicts.

## Quick Conflict Guide

| Key Space | Owner | Notes |
| --------- | ----- | ----- |
| `M-h/j/k/l` | tmux-tilish + tmux.nvim | Pane/split navigation, vim-aware |
| `M-1` to `M-9` | tmux-tilish | Switch windows |
| `M-Tab` | tmux-tilish | Last active window |
| `M-Enter` | tmux-tilish | New pane |
| `M-b` | tmux-harpoon | Fuzzy-jump sessions |
| `M-a` | tmux-harpoon | Jump to slot 2 |
| `C-S-a` | tmux-harpoon | Jump to slot 1 |
| `C-S-h` | tmux-harpoon | Add session |
| `C-a` | tmux prefix | — |
| `Super+…` | LeftWM | Window manager (Linux only) |
| `Hyper+…` | Hammerspoon | App launchers (macOS only) |
| `<Space>` | Neovim leader | — |

## Component References

| Component | File | Platform |
| --------- | ---- | -------- |
| Kanata (keyboard layers) | [kanata/keybindings.md](../private_dot_config/kanata/keybindings.md) | All |
| Tmux | [tmux/keybindings.md](../private_dot_config/tmux/keybindings.md) | All |
| Neovim | [nvim/keybindings.md](../private_dot_config/nvim/keybindings.md) | All |
| LeftWM | [leftwm/keybindings.md](../private_dot_config/leftwm/keybindings.md) | Linux |

## Layer Overview

```text
Physical keys
  └── Kanata (remapping: CapsLock→Ctrl/Esc, Space→Nav layer, etc.)
        └── Terminal / tmux (prefix=C-a, tilish M-keys, harpoon)
              └── Neovim (leader=Space, harpoon2, leap)
LeftWM / Hammerspoon (Super/Hyper — window manager level, bypass tmux)
```

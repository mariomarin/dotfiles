# Tmux Remote Setup

## SSH + Tmux Workflow

```bash
ssh user@remote
tmux attach -t work  # or: tmux new -s work
```

## Clipboard Integration

Tmux clipboard automatically detects environment:

- **Linux**: xclip or wl-copy
- **WSL**: clip.exe
- **macOS**: pbcopy

Copy in tmux:

1. `Ctrl+a [` - Enter copy mode
2. `v` - Start selection
3. `y` - Copy to system clipboard

## Navigation with Neovim

Seamless navigation between tmux panes and nvim splits:

- `M-h/j/k/l` - Navigate panes/splits (unified)
- Works via tmux.nvim plugin

See [tmux-navigation.lua](../nvim/lua/plugins/tmux-navigation.lua) for config.

## Key Plugins

- **tmux-resurrect**: Save/restore sessions (`prefix C-s`, `prefix C-r`)
- **tmux-fingers**: Quick copy (`M-f`)
- **extrakto**: Extract text (`prefix Tab`)

See [KEYBINDINGS.md](KEYBINDINGS.md) for complete reference.

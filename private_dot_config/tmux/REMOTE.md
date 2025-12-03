# Tmux Remote

## Clipboard Auto-Detection

Tmux automatically uses the right clipboard:

- **Linux**: xclip or wl-copy
- **WSL**: clip.exe
- **macOS**: pbcopy

Configured in: [copy-mode-vi.tmux](mappings/copy-mode-vi.tmux)

## Copy Mode

1. `Ctrl+a [` - Enter copy mode
2. `v` - Start selection
3. `y` - Copy to system clipboard

## Quick Copy Plugins

- **tmux-fingers** (`M-f`) - Highlight text, type letter to copy
- **extrakto** (`prefix Tab`) - Extract URLs/paths/text

See [KEYBINDINGS.md](KEYBINDINGS.md)

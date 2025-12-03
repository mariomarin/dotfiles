# Multi-Machine Setup

## How It Works

### SSH + Tmux + Clipboard

1. SSH connects to remote
2. Tmux auto-detects environment (WSL/Linux/macOS)
3. Sets clipboard: clip.exe/xclip/pbcopy
4. Copy in tmux → Available locally

### Unified Navigation

`M-h/j/k/l` works across tmux panes AND nvim splits (via tmux.nvim)

### Typical Workflow

```bash
ssh user@remote
tmux attach -t work || tmux new -s work
# M-h/j/k/l navigates everywhere
# Copy/paste works across nvim/tmux
```

## See Also

- [REMOTE_CONNECTIONS.md](REMOTE_CONNECTIONS.md) - How to connect
- [tmux/REMOTE.md](../private_dot_config/tmux/REMOTE.md) - Tmux clipboard
- [nvim/REMOTE.md](../private_dot_config/nvim/REMOTE.md) - Nvim integration

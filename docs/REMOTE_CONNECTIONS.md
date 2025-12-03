# Remote Connections

## Cloudflare Tunnel

```bash
# On remote
cloudflared tunnel --url ssh://localhost:22
# Returns: https://random-name.trycloudflare.com

# On local
export CLOUDFLARE_TUNNEL_HOST=random-name.trycloudflare.com
cf-ssh
```

## Direct SSH

```bash
ssh user@hostname
```

## VS Code Remote SSH

1. Install "Remote - SSH" extension
2. `Ctrl+Shift+P` → "Remote-SSH: Connect"
3. Enter `user@hostname`

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

See also: [tmux/REMOTE.md](../private_dot_config/tmux/REMOTE.md), [nvim/REMOTE.md](../private_dot_config/nvim/REMOTE.md)

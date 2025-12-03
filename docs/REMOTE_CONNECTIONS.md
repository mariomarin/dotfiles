# Remote Connections

Quick guide for connecting to remote machines via SSH and Cloudflare Tunnel.

## Cloudflare Tunnel (Simplest)

### On Remote Machine (WSL, server, etc)

```bash
cloudflared tunnel --url ssh://localhost:22
```

Returns: `https://random-name.trycloudflare.com`

### On Local Machine

```bash
export CLOUDFLARE_TUNNEL_HOST=random-name.trycloudflare.com
cf-ssh
```

## Direct SSH

### Standard Connection

```bash
ssh user@hostname
tmux attach  # or: tmux new -s work
```

### VS Code Remote SSH

1. Install "Remote - SSH" extension
2. `Ctrl+Shift+P` → "Remote-SSH: Connect to Host"
3. Enter: `user@hostname`
4. Open folder, edit as if local

## See Also

- [Tmux Remote Setup](../private_dot_config/tmux/REMOTE.md) - Clipboard, navigation
- [Neovim Remote Setup](../private_dot_config/nvim/REMOTE.md) - SSH integration
- [Multi-Machine Setup](MULTI_MACHINE.md) - Full workflow

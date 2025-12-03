# Multi-Machine Setup

Complete workflow for working across multiple machines.

## Quick Reference

### Cloudflare Tunnel (Behind Firewall)

```bash
# On remote (WSL, server)
cloudflared tunnel --url ssh://localhost:22
# Returns: https://random.trycloudflare.com

# On local
export CLOUDFLARE_TUNNEL_HOST=random.trycloudflare.com
cf-ssh
```

### Direct SSH

```bash
ssh user@hostname
tmux attach -t work
```

### VS Code Remote

1. Install "Remote - SSH" extension
2. `Ctrl+Shift+P` → "Remote-SSH: Connect"
3. Enter `user@hostname`

## How It Works

### SSH + Tmux + Clipboard

**Flow:**

1. SSH connects to remote machine
2. Tmux detects environment (WSL/Linux/macOS)
3. Sets appropriate clipboard command (clip.exe/xclip/pbcopy)
4. Copy in tmux → Available on local system

**Copy in Tmux:**

- `Ctrl+a [` → copy mode
- `v` → select, `y` → copy
- Or: `M-f` → tmux-fingers (quick copy)

See: [tmux/REMOTE.md](../private_dot_config/tmux/REMOTE.md)

### Neovim + Tmux Navigation

**Unified keybindings:**

- `M-h/j/k/l` - Navigate between nvim splits AND tmux panes
- No mode switching needed
- Works via tmux.nvim plugin

**Clipboard integration:**

- Neovim and tmux share clipboard
- Copy in nvim → paste in tmux
- Copy in tmux → paste in nvim

See: [nvim/REMOTE.md](../private_dot_config/nvim/REMOTE.md)

### VS Code Remote SSH

**How it works:**

1. VS Code connects via SSH
2. Installs VS Code Server on remote
3. Local UI, remote execution
4. Terminal uses remote shell

**Clipboard:**

- Automatic via VS Code's remote extension
- Copy/paste works like local

## Typical Workflow

```bash
# 1. Connect
ssh user@remote
# or: cf-ssh (via Cloudflare Tunnel)

# 2. Start/attach tmux
tmux attach -t work || tmux new -s work

# 3. Navigate seamlessly
# - M-h/j/k/l works everywhere
# - Copy/paste works across tools

# 4. Disconnect safely
# Just close terminal - tmux keeps running
```

## See Also

- [REMOTE_CONNECTIONS.md](REMOTE_CONNECTIONS.md) - Connection methods
- [tmux/REMOTE.md](../private_dot_config/tmux/REMOTE.md) - Tmux setup
- [nvim/REMOTE.md](../private_dot_config/nvim/REMOTE.md) - Neovim setup

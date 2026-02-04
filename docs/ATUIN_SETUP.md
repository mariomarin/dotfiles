# Atuin Setup Guide

Atuin provides encrypted, synced shell history across all your machines.

## Overview

- **Server**: Self-hosted on internal work server
- **Clients**: macOS (darwin-brew), Ubuntu (linux-apt)
- **Sync**: Automatic every 5 minutes
- **Security**: End-to-end encrypted with your sync key

## Server Setup (Ubuntu/Debian)

### 1. Install Atuin

Atuin is automatically installed via chezmoi external on linux-apt platforms.

### 2. Initialize Server Database

```bash
# Create config directory
mkdir -p ~/.config/atuin

# Generate server config
cat > ~/.config/atuin/server.toml << 'EOF'
host = "0.0.0.0"
port = 8888
open_registration = false  # Disable open registration after setup
path = "~/.local/share/atuin/server"
EOF

# Initialize database
atuin server init
```

### 3. Create Server User

```bash
# Register your user account
atuin server register <username> <email> <password>
```

### 4. Run Server

#### Option A: Systemd Service (recommended)

```bash
# Create systemd service
mkdir -p ~/.config/systemd/user

cat > ~/.config/systemd/user/atuin.service << 'EOF'
[Unit]
Description=Atuin Shell History Server
After=network.target

[Service]
Type=simple
ExecStart=%h/.local/bin/atuin server start
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
EOF

# Enable and start service
systemctl --user daemon-reload
systemctl --user enable atuin.service
systemctl --user start atuin.service

# Check status
systemctl --user status atuin
```

#### Option B: Tmux/Screen Session

```bash
# Run in background
tmux new-session -d -s atuin 'atuin server start'
```

### 5. Expose Server (Optional: Cloudflare Tunnel)

If your server is behind NAT/firewall, use Cloudflare Tunnel:

```bash
# Install cloudflared (already via chezmoi)
# Login to Cloudflare
cloudflared tunnel login

# Create tunnel
cloudflared tunnel create atuin-history

# Route to local server
cloudflared tunnel route dns atuin-history atuin.yourdomain.com

# Run tunnel
cloudflared tunnel run atuin-history --url http://localhost:8888
```

## Client Setup

### 1. Generate Sync Key

On any client machine:

```bash
# Generate encryption key (save this!)
atuin key

# This generates a key like:
# atuin_1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcd
```

**IMPORTANT**: Save this key securely! You need it on all clients.

### 2. Configure Environment Variables

Create `~/.local/share/chezmoi/.env.work` (NOT tracked in git):

```bash
# Atuin sync configuration
export ATUIN_SYNC_ADDRESS="http://your-server:8888"
export ATUIN_SYNC_KEY="atuin_your_key_here"
```

### 3. Reload Environment

```bash
# In the dotfiles repo directory
direnv allow

# Or restart your shell
exec zsh
```

### 4. Login to Server

```bash
# Login with credentials from server setup
atuin login -u <username> -p <password>

# Or use key directly
atuin login -u <username> -k <password>
```

### 5. Import Existing History (First Time Only)

```bash
# Import your existing shell history
atuin import auto

# Or import from specific shell
atuin import zsh
atuin import bash
```

### 6. Sync History

```bash
# Manual sync (optional, auto-syncs every 5min)
atuin sync
```

## Verification

### Check Sync Status

```bash
# View sync status
atuin status

# Should show:
# - Sync: enabled
# - Last sync: <timestamp>
# - Records: <count>
```

### Test Search

```bash
# Press Ctrl+R in your shell to search history
# Should see history from all synced machines
```

## Troubleshooting

### Connection Issues

```bash
# Test server connectivity
curl http://your-server:8888/health

# Check environment variables
echo $ATUIN_SYNC_ADDRESS
echo $ATUIN_SYNC_KEY
```

### Sync Not Working

```bash
# Check config
atuin status

# Force sync
atuin sync -f

# View logs (if using systemd)
journalctl --user -u atuin -f
```

### Reset Client

```bash
# Clear local database (keeps config)
rm -rf ~/.local/share/atuin/history.db

# Re-import and sync
atuin import auto
atuin sync
```

## Security Notes

- **Encryption**: History is encrypted with your sync key before leaving your machine
- **Key Management**: Never commit sync key to git - use `.env.work`
- **Server Access**: Run server on internal network or use Cloudflare Tunnel
- **Registration**: Disable `open_registration` after creating accounts

## References

- [Atuin Documentation](https://docs.atuin.sh/)
- [Self-Hosting Guide](https://docs.atuin.sh/self-hosting/server-setup/)
- [Configuration Reference](https://docs.atuin.sh/configuration/config/)

# Cloudflare Tunnel Setup

Cloudflare Tunnel provides secure remote access without exposing ports or configuring firewalls.

## Why Cloudflare Tunnel?

- **No port forwarding**: Works through restrictive firewalls
- **Production-ready**: Used by enterprises, free for personal use
- **Secure**: Traffic encrypted end-to-end
- **No public IP needed**: Works from behind NAT
- **Better than upterm/tmate**: More reliable, doesn't require complex SSH auth

## Prerequisites

- Cloudflare account (free): <https://dash.cloudflare.com/sign-up>
- `cloudflared` installed (already in minimal.nix)

## Quick Start - SSH Access

### 1. Authenticate cloudflared

```bash
# Login to Cloudflare (opens browser)
cloudflared tunnel login
```

### 2. Create a Tunnel

```bash
# Create a named tunnel
cloudflared tunnel create my-wsl

# This creates:
# - Tunnel credentials in ~/.cloudflared/
# - Tunnel ID (save this!)
```

### 3. Create Configuration File

```bash
mkdir -p ~/.cloudflared
cat > ~/.cloudflared/config.yml <<EOF
tunnel: <TUNNEL_ID>
credentials-file: /home/mario/.cloudflared/<TUNNEL_ID>.json

ingress:
  # SSH access
  - hostname: ssh.example.com
    service: ssh://localhost:22
  # Catch-all rule (required)
  - service: http_status:404
EOF
```

### 4. Route DNS to Your Tunnel

```bash
# Associate a hostname with your tunnel
cloudflared tunnel route dns my-wsl ssh.example.com
```

### 5. Run the Tunnel

```bash
# Start tunnel
cloudflared tunnel run my-wsl

# Or run as background service
cloudflared tunnel run --background my-wsl
```

### 6. Connect from Client

```bash
# On dendrite or any other machine
ssh mario@ssh.example.com
```

## Quick Start - Quick Tunnels (No Setup)

For temporary sharing without DNS setup:

```bash
# On WSL - expose SSH temporarily
cloudflared tunnel --url ssh://localhost:22

# Returns: https://random-name.trycloudflare.com
# Share this URL with others
```

## Common Use Cases

### Share Tmux Session

```bash
# On WSL - run tunnel
cloudflared tunnel run my-wsl

# On client - connect via SSH
ssh mario@ssh.example.com
tmux attach
```

### Expose Web Server

```yaml
# Add to ~/.cloudflared/config.yml
ingress:
  - hostname: app.example.com
    service: http://localhost:3000
  - service: http_status:404
```

### Multiple Services

```yaml
ingress:
  # SSH
  - hostname: ssh.example.com
    service: ssh://localhost:22
  # Web app
  - hostname: app.example.com
    service: http://localhost:3000
  # Another service
  - hostname: api.example.com
    service: http://localhost:8080
  # Required catch-all
  - service: http_status:404
```

## Managing Tunnels

```bash
# List tunnels
cloudflared tunnel list

# Get tunnel info
cloudflared tunnel info my-wsl

# Delete tunnel
cloudflared tunnel delete my-wsl

# View tunnel logs
journalctl -u cloudflared -f  # if running as systemd service
```

## Running as a Service

### Systemd (Linux)

```bash
# Install service
sudo cloudflared service install

# Start service
sudo systemctl start cloudflared
sudo systemctl enable cloudflared

# Check status
sudo systemctl status cloudflared
```

## Security Notes

- Tunnel credentials are stored in `~/.cloudflared/`
- Keep credential files secure (they're like API keys)
- Use Cloudflare Access for additional authentication layers
- Traffic is encrypted through Cloudflare's network

## Troubleshooting

### Tunnel won't start

```bash
# Check configuration
cloudflared tunnel info my-wsl

# Test connectivity
cloudflared tunnel run --loglevel debug my-wsl
```

### DNS not resolving

```bash
# Verify DNS route
cloudflared tunnel route dns my-wsl ssh.example.com

# Check DNS propagation
dig ssh.example.com
```

### Connection refused

- Ensure local service is running (e.g., SSH server)
- Check firewall allows cloudflared to reach localhost
- Verify service URL in config.yml

## Resources

- [Official Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Tunnel Examples](https://github.com/cloudflare/cloudflared/tree/master/examples)
- [Cloudflare Dashboard](https://dash.cloudflare.com/)

## Comparison with Alternatives

| Feature | Cloudflare Tunnel | upterm | tmate | rathole |
|---------|------------------|--------|-------|---------|
| Setup | Medium | Easy | Easy | Complex |
| Reliability | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Firewall bypass | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Production ready | Yes | No | Yes | Yes |
| Self-hosted | Optional | Required | Optional | Required |
| Cost | Free | Free | Free | Free |

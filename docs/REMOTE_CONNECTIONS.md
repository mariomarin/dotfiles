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

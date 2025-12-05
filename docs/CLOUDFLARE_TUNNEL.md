# Cloudflare Tunnel with cf-vault

Cloudflare Tunnel provides secure remote access without exposing ports.

## Why cf-vault?

- **Secure credentials**: Stores API tokens in OS keyring (macOS Keychain, GNOME Keyring, Windows Credential Manager)
- **No Bitwarden needed**: Dedicated tool for Cloudflare credentials
- **API access**: Query active tunnels, manage resources programmatically
- **Profile-based**: Separate profiles for different accounts/use cases

## Prerequisites

- Cloudflare account: <https://dash.cloudflare.com/sign-up>
- `cloudflared` and `cf-vault` (both in minimal.nix)

## Quick Start

### 1. Setup cf-vault Profile

```bash
just tunnel-setup

# Follow prompts:
# - Enter API token from dash.cloudflare.com
# - Token is stored in system keyring
```

### 2. Set Account ID

```bash
# Get from Cloudflare dashboard
export CF_ACCOUNT_ID="your-account-id"

# Add to ~/.zshenv or ~/.bashrc
echo 'export CF_ACCOUNT_ID="your-account-id"' >> ~/.zshenv
```

### 3. Start and Query Tunnel

```bash
# Start SSH tunnel (temporary URL)
just tunnel-ssh

# Query tunnel status (shows URL)
just tunnel-status

# Or list all active tunnels via API
just tunnel-list
```

## Common Commands

| Command | Description |
|---------|-------------|
| `just tunnel-setup` | Setup cf-vault profile |
| `just tunnel-ssh` | Quick SSH tunnel (port 22) |
| `just tunnel-http 3000` | HTTP server tunnel |
| `just tunnel-list` | List active tunnels via API |
| `just tunnel-status` | Show running tunnel |
| `just tunnel-stop` | Stop tunnel |

## Advanced: cf-vault Usage

```bash
# List configured profiles
cf-vault list

# Add another profile
cf-vault add production

# Use specific profile
nu .scripts/cloudflare-tunnel.nu tunnel list --profile production

# Delete profile
cf-vault delete cloudflare
```

## Resources

- [cf-vault](https://github.com/jacobbednarz/cf-vault)
- [Cloudflare Tunnel Docs](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Cloudflare API](https://developers.cloudflare.com/api/)

# Secrets Management

This repository uses Bitwarden to securely store and manage secrets like SSH keys, API tokens, and other sensitive
information.

## Overview

Chezmoi templates can fetch secrets from Bitwarden using the `bitwarden` template function. This allows you to store
sensitive data securely in your Bitwarden vault and have it automatically inserted into your dotfiles during
`chezmoi apply`.

## Setup

### 1. Install Bitwarden CLI

The Bitwarden CLI is automatically installed during the bootstrap process:

- **macOS**: Installed via Nix during bootstrap
- **Linux (NixOS)**: Expected to be installed system-wide
- **Windows**: Installed via winget during bootstrap

### 2. Login to Bitwarden

```bash
bw login <your-email>
```

### 3. Unlock Vault

Before applying dotfiles, you need to unlock your Bitwarden vault and set the session token:

**Unix/macOS:**

```bash
export BW_SESSION=$(bw unlock --raw)
```

**Windows (PowerShell):**

```powershell
$env:BW_SESSION = bw unlock --raw
```

## Creating SSH Key Items in Bitwarden

### Method 1: CLI (Unix/macOS)

```bash
# Encode your SSH keys and create the item
bw get template item | jq \
  '.type = 5 | .name = "id_ed25519" | .sshKey = {
    "privateKey": "'$(cat ~/.ssh/id_ed25519)'",
    "publicKey": "'$(cat ~/.ssh/id_ed25519.pub)'"
  }' | bw encode | bw create item
```

### Method 2: Web Vault (All Platforms)

1. Open your Bitwarden web vault
2. Click "New Item"
3. Select item type: **SSH Key**
4. Name: `id_ed25519` (or your preferred name)
5. Paste your private key in the "Private Key" field
6. Paste your public key in the "Public Key" field
7. Save the item

## Usage in Templates

Chezmoi templates can reference Bitwarden items using the `bitwarden` function:

```go-template
{{- /* SSH private key */ -}}
{{ (bitwarden "item" "id_ed25519").sshKey.privateKey }}

{{- /* SSH public key */ -}}
{{ (bitwarden "item" "id_ed25519").sshKey.publicKey }}
```

## Workflow

### Quick Workflow (Unix/macOS)

```bash
# 1. Unlock vault and save session
make bw-unlock

# 2. Reload environment to load session
make bw-reload

# 3. Apply dotfiles (SSH keys are fetched from Bitwarden)
make
```

### Manual Workflow (Unix/macOS)

```bash
# Unlock and export session
export BW_SESSION=$(bw unlock --raw)

# Apply dotfiles
chezmoi apply -v
```

### Manual Workflow (Windows)

```powershell
# Unlock and export session in PowerShell
$env:BW_SESSION = bw unlock --raw

# Apply dotfiles
chezmoi apply -v
```

**Note**: On Windows, `direnv` is available but `devenv.nix` (which provides the `make` targets) is not. Use the manual
PowerShell workflow above instead of `make` commands.

## How It Works

### Session Management

- `just bw-unlock` unlocks the vault and saves the session token to `.env.local` (git-ignored)
- `just bw-reload` reloads direnv and validates the session (checks if vault is still unlocked)
- The session persists until you run `bw lock` or `bw logout` (no automatic expiration)
- Session validation helps detect expired or locked sessions
- **Auto-loading**: `justfile` automatically loads `.env.local` for all commands via `set dotenv-load`

### Template Processing

- During `chezmoi apply`, templates are processed and the `bitwarden` function is evaluated
- The function uses the `BW_SESSION` environment variable to authenticate with Bitwarden
- Secrets are fetched from your vault and inserted into the generated files

### Security Considerations

- The `BW_SESSION` token is stored in `.env.local`, which is git-ignored (standard convention)
- Session tokens expire when you lock or logout from Bitwarden
- SSH keys and other secrets are only stored in your Bitwarden vault, not in the git repository
- Chezmoi's auto-commit feature will not commit the generated files containing secrets (they're in your home directory,
  not the source directory)

## SSH Key Item Structure

SSH Key items in Bitwarden (type 5) have the following structure:

- `.sshKey.privateKey` - Private key content
- `.sshKey.publicKey` - Public key content
- `.sshKey.keyFingerprint` - Key fingerprint

## Troubleshooting

### "bw: command not found"

The Bitwarden CLI is installed during the bootstrap process. If you encounter this error:

1. Run `chezmoi init` or `chezmoi apply` to trigger the bootstrap process
2. On NixOS, ensure `bitwarden-cli` is installed system-wide

### "Session key is invalid"

Your Bitwarden session has expired or the `BW_SESSION` variable is not set:

1. Unlock your vault: `bw unlock`
2. Export the session token as shown in the unlock command output
3. Re-run `chezmoi apply`

### Templates fail with Bitwarden errors

Make sure:

1. You're logged in: `bw login`
2. Your vault is unlocked: `bw unlock`
3. The `BW_SESSION` environment variable is set
4. The item name in your template matches the name in your Bitwarden vault

## Additional Resources

- [Bitwarden CLI Documentation](https://bitwarden.com/help/cli/)
- [Chezmoi Bitwarden Integration](https://www.chezmoi.io/user-guide/password-managers/bitwarden/)

# Installation Scripts

One-line bootstrap for automated setup.

## Quick Start

| Platform | Command |
|----------|---------|
| **macOS/NixOS** | `curl -sfL https://raw.githubusercontent.com/mariomarin/dotfiles/main/.install/bootstrap-unix.sh \| sh` |
| **Windows** | `irm https://raw.githubusercontent.com/mariomarin/dotfiles/main/.install/bootstrap-windows.ps1 \| iex` |

Bootstrap installs package managers, clones repo, prompts for hostname, sets up Bitwarden, and applies configuration. Override hostname: `export HOSTNAME="name"` (before running).

## Secret Management

`just bw-setup` → saves session to `.env.local` → `just` auto-loads via `set dotenv-load` → chezmoi templates fetch secrets → topgrade validates session. No manual `export` needed

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Execution policy (Windows)** | `Set-ExecutionPolicy Bypass -Scope Process -Force` |
| **Restart required (Windows)** | Restart PowerShell after tools install |
| **bitwarden-cli missing (NixOS)** | `nix-env -iA nixos.bitwarden-cli` |

**Platforms:** Windows (winget DSC), macOS (nix-darwin), NixOS (nixos-rebuild). Other Linux not supported.

**Security:** Review [bootstrap scripts](.install/) before running.

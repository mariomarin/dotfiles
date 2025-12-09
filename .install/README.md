# Installation Scripts

Bootstrap scripts for first-time dotfiles setup.

## Quick Start

| Platform | Install | Initialize | Apply |
|----------|---------|------------|-------|
| **Windows** | [Git](https://git-scm.com/download/win) + `iex "&{$(irm 'https://get.chezmoi.io/ps1')}"` | `chezmoi init https://github.com/mariomarin/dotfiles.git` | `bw login && $env:BW_SESSION = bw unlock --raw && chezmoi apply -v` |
| **macOS** | `curl -sfL https://install.determinate.systems/nix \| sh -s -- install` | `git clone https://github.com/mariomarin/dotfiles.git ~/.local/share/chezmoi && cd ~/.local/share/chezmoi && nix-shell .install/shell.nix` | `chezmoi init && bw login && export BW_SESSION=$(bw unlock --raw) && chezmoi apply -v && just darwin-first-time` |
| **NixOS** | `nix-shell -p git --run "git clone https://github.com/mariomarin/dotfiles.git ~/.local/share/chezmoi"` | `cd ~/.local/share/chezmoi && nix-shell .install/shell.nix` | `chezmoi init && bw login && export BW_SESSION=$(bw unlock --raw) && chezmoi apply -v && cd nix/nixos && sudo nixos-rebuild switch --flake .#dendrite` |

> **Note:** Hostname auto-detected from system. Override: `export HOSTNAME="name"` (Unix) or `$env:HOSTNAME = "name"` (Windows)

## What Gets Installed

**Bootstrap (automatic):**
- Windows: winget, nushell, bitwarden-cli
- macOS: nix, nushell, bitwarden-cli (via nix-shell)
- NixOS: nushell, bitwarden-cli (via nix-shell)

**System packages (via final just command):**
- Windows: `just windows-configure` (winget DSC)
- macOS: `just darwin` (nix-darwin)
- NixOS: `just nixos` (nixos-rebuild)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| **Windows: winget not found** | Auto-installed by bootstrap via [asheroto/winget-install](https://github.com/asheroto/winget-install)<br>Manual: `irm https://get.winget.run \| iex` |
| **Windows: Execution policy** | `Set-ExecutionPolicy Bypass -Scope Process -Force` |
| **Windows: Restart required** | Restart PowerShell after bootstrap installs nushell |
| **NixOS: bitwarden-cli missing** | `nix-env -iA nixos.bitwarden-cli` |
| **macOS: Nix install fails** | `curl -sfL https://install.determinate.systems/nix \| sh -s -- install` |

## Supported Platforms

- ✅ Windows (via winget)
- ✅ macOS (via nix-darwin)
- ✅ NixOS (via nixos-rebuild)
- ❌ Other Linux (install NixOS or use NixOS-WSL)

## Security

Review scripts before running. Bootstrap installs only what templates require.

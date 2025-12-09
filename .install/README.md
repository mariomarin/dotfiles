# Installation Scripts

Bootstrap scripts for first-time setup on new machines.

## Quick Start

| Platform | Prerequisites | Setup Command |
|----------|--------------|---------------|
| **Windows** | Git, chezmoi | `chezmoi init https://github.com/mariomarin/dotfiles.git` |
| **macOS** | Nix | `nix-shell .install/shell.nix` → `chezmoi init` |
| **NixOS** | git, chezmoi | `chezmoi init` |

> **Hostname override:** Set `HOSTNAME` env var before init: `export HOSTNAME="malus"` (Unix) or `$env:HOSTNAME = "prion"` (Windows)

## Platform-Specific Setup

### Windows

**Prerequisites:**

```powershell
# Install Git: https://git-scm.com/download/win
# Install chezmoi
iex "&{$(irm 'https://get.chezmoi.io/ps1')}"
```

**Setup:**

```powershell
# Initialize (auto-installs winget, nushell, bitwarden-cli)
chezmoi init https://github.com/mariomarin/dotfiles.git

# Restart PowerShell if nushell was just installed

# Login and apply
bw login
$env:BW_SESSION = bw unlock --raw
chezmoi apply -v
```

**Bootstrap installs:** winget, nushell, bitwarden-cli
**Packages managed by:** winget DSC (`just windows-configure`)

### macOS

**Prerequisites:**

```bash
# Install Nix
curl -sfL https://install.determinate.systems/nix | sh -s -- install

# Clone and enter bootstrap shell
git clone https://github.com/mariomarin/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
nix-shell .install/shell.nix
```

**Setup:**

```bash
# Initialize and apply
chezmoi init
bw login
export BW_SESSION=$(bw unlock --raw)
chezmoi apply -v

# Apply system configuration (installs all packages)
just darwin-first-time
```

**Bootstrap provides:** chezmoi, just, nushell, bitwarden-cli (via nix-shell)
**Packages managed by:** nix-darwin (`just darwin`)

### NixOS

**Prerequisites:**

```bash
# Option 1: Bootstrap shell (first-time)
nix-shell -p git --run "git clone https://github.com/mariomarin/dotfiles.git ~/.local/share/chezmoi"
cd ~/.local/share/chezmoi
nix-shell .install/shell.nix

# Option 2: System packages (permanent)
# Add to /etc/nixos/configuration.nix: nushell, bitwarden-cli, git, chezmoi
sudo nixos-rebuild switch
```

**Setup:**

```bash
# Initialize and apply
chezmoi init
bw login
export BW_SESSION=$(bw unlock --raw)
chezmoi apply -v

# Apply system configuration
cd nix/nixos
sudo nixos-rebuild switch --flake .#dendrite  # or .#mitosis, .#symbiont
```

**Bootstrap provides:** chezmoi, just, nushell, bitwarden-cli (via nix-shell)
**Packages managed by:** NixOS configuration (`just nixos`)

## How It Works

1. **Bootstrap** (pre-hook): Installs minimal tools needed for templates
2. **chezmoi init**: Reads hostname (from `HOSTNAME` env or system), clones dotfiles
3. **chezmoi apply**: Processes templates, applies dotfiles, runs scripts
4. **System config**: Installs all packages declaratively (nix-darwin/NixOS/winget)

## Supported Platforms

- ✅ **Windows** (via winget)
- ✅ **macOS** (via nix-darwin)
- ✅ **NixOS** (via nixos-rebuild)
- ❌ **Other Linux** (not supported - install NixOS or use NixOS-WSL)

## Troubleshooting

**Windows: winget not found**
- Bootstrap auto-installs via [asheroto/winget-install](https://github.com/asheroto/winget-install)
- Manual: `irm https://get.winget.run | iex`

**Windows: Execution policy error**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

**NixOS: bitwarden-cli not found**
```bash
nix-env -iA nixos.bitwarden-cli
```

**macOS: Nix installation fails**
```bash
curl -sfL https://install.determinate.systems/nix | sh -s -- install
```

## Security Note

Review scripts before running. Bootstrap only installs what templates require.

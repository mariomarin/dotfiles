# NixOS on WSL Configuration

Minimal, headless NixOS configuration for Windows Subsystem for Linux (WSL2).

## Philosophy

This WSL configuration is designed for:

- **CLI-only development** via browser (MS DevBox) or SSH
- **Minimal system packages** - only core tools
- **Per-project tooling** via `devenv.nix` in each repository
- **Container-based workflows** with Docker
- **Headless operation** - no GUI applications

## Features

✅ **Enabled:**
- Full NixOS with flakes
- Systemd support
- Windows interop (run `.exe` from Linux)
- Docker for containers
- SSH server
- Core CLI tools (git, tmux, neovim, modern replacements)
- WSL utilities (wslu)

❌ **Disabled:**
- All GUI applications (use Windows host)
- Desktop environment and X11
- Audio services (use Windows audio)
- Hardware-specific services (Bluetooth, TLP, KMonad)
- NetworkManager (uses WSL networking)

## Initial Setup

### 1. Install WSL2 on Windows

```powershell
# PowerShell as Administrator
wsl --install
```

### 2. Import NixOS-WSL

Download the latest NixOS-WSL tarball from:
https://github.com/nix-community/NixOS-WSL/releases

```powershell
# Import NixOS distribution
wsl --import NixOS $env:USERPROFILE\NixOS\ nixos-wsl.tar.gz --version 2

# Start WSL
wsl -d NixOS
```

### 3. Initial Configuration

```bash
# Inside WSL - clone dotfiles
sudo nix-shell -p git
git clone https://github.com/YOUR_USERNAME/dotfiles.git /tmp/dotfiles

# Apply with chezmoi
sudo nix-shell -p chezmoi
chezmoi init --apply YOUR_USERNAME

# Or manually copy NixOS config
sudo cp -r /tmp/dotfiles/nixos /etc/nixos
```

### 4. Build and Switch

```bash
# Build and switch to new configuration
cd /etc/nixos
sudo nixos-rebuild switch --flake .#nixos-wsl
```

## Daily Usage

### Rebuild Configuration

```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos-wsl
```

### Access Windows Filesystem

```bash
# Windows drives are mounted under /mnt
cd /mnt/c/Users/YourUsername
cd /mnt/d/Projects
```

### Run Windows Commands

```bash
# Open Windows Explorer
explorer.exe .

# Run PowerShell
powershell.exe -Command "Get-Process"

# Open files with default Windows app
wslview file.pdf
```

### Docker Usage

```bash
# Docker daemon starts automatically
docker run hello-world

# Docker Compose
docker compose up -d
```

### Port Forwarding

WSL2 automatically forwards ports to Windows. Dev servers running on `localhost:3000` in WSL are accessible from Windows browsers at `localhost:3000`.

## Development Workflow

### Per-Repository Tooling

This configuration intentionally keeps system packages minimal. Use `devenv.nix` in each project:

```bash
cd /path/to/project

# If project has devenv.nix
devenv shell

# Or use direnv
echo "use devenv" > .envrc
direnv allow
```

Example `devenv.nix`:

```nix
{ pkgs, ... }:

{
  packages = with pkgs; [
    nodejs_20
    go
    postgresql
  ];

  languages.javascript.enable = true;

  services.postgres = {
    enable = true;
    initialDatabases = [{ name = "myapp"; }];
  };
}
```

### System Tools

The system provides only essentials:

- **Shell**: zsh with tmux
- **Editor**: neovim
- **VCS**: git, lazygit, gh
- **Modern CLI**: bat, eza, ripgrep, fd, delta, bottom
- **Containers**: docker
- **Utilities**: curl, wget, jq, yq

Everything else comes from per-project `devenv.nix`.

## Configuration Structure

```
nixos/hosts/wsl/
├── configuration.nix    # WSL-specific settings
└── README.md           # This file

nixos/modules/
└── wsl.nix             # WSL module (auto-included)
```

## Limitations

### What Doesn't Work in WSL

❌ Boot loader or kernel configuration
❌ Hardware-specific services (Bluetooth, fingerprint, battery)
❌ Keyboard remapping (KMonad, xremap)
❌ NetworkManager (uses WSL networking)
❌ Traditional display managers (use WSLg if needed)
❌ Audio services (use Windows audio)

### Workarounds

- **GUI apps**: Install on Windows host
- **Audio**: Use Windows audio output
- **Hardware**: Access via Windows
- **Networking**: Managed by Windows

## Troubleshooting

### WSL Not Starting

```powershell
# Check WSL version
wsl --version

# Update WSL
wsl --update

# Check status
wsl --status
```

### Docker Not Working

```bash
# Check Docker daemon
systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Check user groups
groups  # Should include 'docker'
```

### Systemd Issues

```bash
# Check systemd is running
ps aux | grep systemd

# View system journal
journalctl -xe
```

### Rebuild Fails

```bash
# Check flake syntax
nix flake check /etc/nixos

# Try build without switch
sudo nixos-rebuild build --flake /etc/nixos#nixos-wsl

# View build log
nix log /nix/store/...
```

### Chezmoi Detection

```bash
# Verify WSL detection
chezmoi data | grep -A5 machineConfig

# Should show:
# machineType: "wsl"
# features.wsl: true
```

## Useful Commands

### WSL Management

```bash
# Stop WSL from PowerShell
wsl --terminate NixOS

# Shutdown all WSL instances
wsl --shutdown

# List distributions
wsl --list --verbose

# Set default
wsl --set-default NixOS
```

### NixOS Commands

```bash
# Update flake inputs
cd /etc/nixos
nix flake update

# Garbage collection
sudo nix-collect-garbage -d

# Search packages
nix search nixpkgs package-name

# Check what's installed
nix-env -q
```

## Integration with Chezmoi

Chezmoi automatically detects WSL via the `WSL_DISTRO_NAME` environment variable.

Machine features for WSL:
- `machineType = "wsl"`
- `desktop = false`
- `kmonad = false`
- `audio = false`
- `bluetooth = false`
- `wsl = true`

Dotfiles can conditionally apply based on these features.

## Related Documentation

- [Main CLAUDE.md](../../CLAUDE.md) - Repository overview
- [NixOS CLAUDE.md](../CLAUDE.md) - NixOS configuration guide
- [NixOS-WSL Documentation](https://github.com/nix-community/NixOS-WSL)
- [WSL Documentation](https://docs.microsoft.com/en-us/windows/wsl/)

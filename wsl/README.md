# WSL NixOS Setup

This directory contains tools to help Windows users set up NixOS on Windows Subsystem for Linux (WSL2).

## Quick Start

From Windows PowerShell or Command Prompt:

```powershell
# Navigate to your dotfiles directory
cd $env:USERPROFILE\.local\share\chezmoi\wsl

# One-command setup (installs everything)
just setup

# Or step-by-step:
just check-wsl          # Check if WSL2 is installed
just download-nixos     # Download latest NixOS-WSL
just import-nixos       # Import into WSL
just set-default        # Set as default distribution
just start-nixos        # Start NixOS WSL
```

## Prerequisites

- **Windows 10/11** with WSL2 support
- **Administrator privileges** (for WSL installation)
- **just** installed on Windows via `winget install casey.just`
- **nushell** installed on Windows (automatically via chezmoi packages)

## Available Commands

### Setup & Installation

- `just setup` - Complete one-command WSL NixOS setup
- `just install-wsl` - Install WSL2 (requires admin)
- `just download-nixos` - Download latest NixOS-WSL tarball
- `just import-nixos` - Import NixOS into WSL
- `just set-default` - Set NixOS as default WSL distribution

### Management

- `just start-nixos` - Start NixOS WSL instance
- `just stop-nixos` - Stop NixOS WSL instance
- `just run COMMAND` - Run a command in NixOS
- `just terminal` - Open NixOS in Windows Terminal
- `just uninstall-nixos` - Remove NixOS from WSL (destructive!)

### Information

- `just check-wsl` - Verify WSL2 installation
- `just list-distros` - List all WSL distributions
- `just info` - Show WSL system information
- `just health` - Health check for WSL setup

## Step-by-Step Guide

### 1. Install WSL2

```powershell
just install-wsl
# Restart computer if prompted
```

### 2. Download and Import NixOS

```powershell
just download-nixos
just import-nixos
```

### 3. Configure NixOS

```powershell
# Start NixOS
just start-nixos

# Inside WSL - install chezmoi
sudo nix-shell -p chezmoi git

# Clone and apply dotfiles
chezmoi init --apply YOUR_USERNAME

# Build NixOS configuration
cd ~/.local/share/chezmoi
just nixos/switch
```

### 4. Set as Default (Optional)

```powershell
just set-default
# Now 'wsl' will start NixOS by default
```

## After Setup

Once NixOS is set up in WSL:

1. **Access NixOS**: Type `wsl` in any terminal
2. **Use chezmoi**: Dotfiles are managed via chezmoi
3. **Update system**: `just nixos/switch` rebuilds NixOS config
4. **Install tools**: Use `nix-shell -p PACKAGE` or add to system config

## Differences from Native NixOS

WSL NixOS is **headless** and **minimal**:

- ✅ Full NixOS with flakes and systemd
- ✅ Docker, SSH, and CLI tools
- ❌ No GUI applications (use Windows host)
- ❌ No audio (use Windows audio)
- ❌ No NetworkManager (uses WSL networking)

See [nixos/hosts/wsl/README.md](../nixos/hosts/wsl/README.md) for detailed WSL NixOS documentation.

## WSL Configuration Files

### .wslconfig (Global WSL Settings)

The `.wslconfig` file controls global WSL2 settings for **all distributions**.

**Location**: `C:\Users\<username>\.wslconfig` (Windows home directory)

**Setup**:

```powershell
# From Windows PowerShell
# The template is provided in this directory as .wslconfig.tmpl
# Copy it to your Windows home directory and customize as needed
copy wsl\dot_wslconfig.tmpl $env:USERPROFILE\.wslconfig

# Edit settings
notepad $env:USERPROFILE\.wslconfig

# Apply changes (restart WSL)
wsl --shutdown
```

**Key Settings**:

- `memory=8GB` - RAM allocation (adjust based on your system)
- `processors=4` - CPU cores (adjust based on your CPU)
- `swap=2GB` - Swap space when memory is full
- `localhostForwarding=true` - Access WSL services from Windows via localhost
- `nestedVirtualization=true` - Required for Docker in WSL

**Note**: This file is **not** managed by chezmoi because it lives in the Windows filesystem, outside the WSL
distribution. You need to manually copy and maintain it.

### wsl.conf (Per-Distribution Settings)

The `wsl.conf` file controls settings for **this specific WSL distribution**.

**Location**: `/etc/wsl.conf` (inside WSL)

**For NixOS WSL**: This file should be managed by your NixOS configuration, **not** chezmoi, because:

1. It's a system file (`/etc/wsl.conf`)
2. NixOS-WSL module already provides sensible defaults
3. System-level changes should go through `nixos-rebuild`

**Recommended settings** (if you need to customize):

Add to your NixOS configuration (`nixos/hosts/wsl/configuration.nix`):

```nix
# WSL-specific configuration
wsl = {
  enable = true;
  defaultUser = "mario";
  startMenuLaunchers = true;

  # Network configuration
  wslConf = {
    network = {
      hostname = "nixos-wsl";
      generateResolvConf = true;
    };

    # Interop settings
    interop = {
      enabled = true;
      appendWindowsPath = true;
    };

    # User settings
    user = {
      default = "mario";
    };

    # Boot settings
    boot = {
      systemd = true;
    };
  };
};
```

Then apply: `sudo nixos-rebuild switch --flake .#nixos-wsl`

**Why not chezmoi?**

- System files in `/etc/` require root access
- NixOS declarative configuration is more reliable for system settings
- Avoids permission and ownership issues
- Integrates with NixOS module system

### Applying Configuration Changes

After modifying `.wslconfig` (Windows side):

```powershell
# Shutdown all WSL distributions
wsl --shutdown

# Wait a few seconds, then start NixOS
wsl -d NixOS
```

After modifying NixOS configuration (WSL side):

```bash
# Inside NixOS WSL
cd ~/.local/share/chezmoi
sudo nixos-rebuild switch --flake .#nixos-wsl
```

## Troubleshooting

### WSL not installed

```powershell
just install-wsl
# Restart computer
```

### NixOS not starting

```powershell
# Check status
just health

# Restart WSL
just stop-nixos
just start-nixos
```

### Download fails

Manually download from: <https://github.com/nix-community/NixOS-WSL/releases>

Then run:

```powershell
just import-nixos
```

## Related Documentation

- [NixOS WSL Configuration](../nixos/hosts/wsl/README.md)
- [NixOS-WSL Project](https://github.com/nix-community/NixOS-WSL)
- [WSL Documentation](https://learn.microsoft.com/en-us/windows/wsl/)

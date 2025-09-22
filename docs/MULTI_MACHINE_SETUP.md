# Multi-Machine Configuration Guide

This repository supports managing configurations for multiple machines with different capabilities using both
Chezmoi and NixOS flakes.

## Overview

The setup distinguishes between:

1. **Physical laptop (T470)**: Full desktop environment, audio, bluetooth, physical keyboard
2. **Headless VMs**: SSH-only access, no GUI, minimal services

## Chezmoi Configuration

### Machine Detection

Chezmoi automatically detects machine type based on hostname:

```yaml
# .chezmoidata/machines.yaml
machines:
  t470:
    type: laptop
    hostname: nixos  # Your T470's hostname
    features:
      desktop: true
      kmonad: true
      
  vm-headless:
    type: server
    hostname_pattern: "vm-*"  # Matches vm-dev, vm-prod, etc.
    features:
      desktop: false
      kmonad: false
```

### Conditional File Management

Files are conditionally managed based on machine features:

```text
# Desktop-only files (won't exist on headless VMs)
~/.config/alacritty/
~/.config/polybar/
~/.local/share/applications/

# Server files (exist on all machines)
~/.config/tmux/
~/.config/nvim/
~/.zshrc
```

### Testing Machine Detection

```bash
# Check detected machine type
chezmoi execute-template '{{ .machineType }}'

# Check machine features
chezmoi execute-template '{{ .machineConfig.features | toJson }}'
```

## NixOS Configuration

### Flake Structure

```text
nixos/
├── flake.nix              # Multi-host flake definition
├── configuration.nix      # Common configuration
├── hardware-configuration.nix  # T470 hardware (symlink on VMs)
├── hosts/
│   ├── t470/
│   │   └── configuration.nix  # Desktop-specific
│   └── vm/
│       └── configuration.nix  # VM-specific
└── modules/
    ├── desktop.nix        # Conditional desktop module
    └── services/
        └── kmonad.nix     # Only enabled on physical machines
```

### Building for Different Hosts

Using make targets (recommended):

```bash
# From repository root
make nixos                      # Build T470 configuration (default)
make vm-switch                  # Build VM configuration locally
make vm-test                    # Test VM config without switching

# Or from nixos directory
cd nixos
make switch                     # Build default (T470)
make HOST=vm-headless switch    # Build VM config
make vm/switch                  # Shortcut for VM
make hosts                      # Show available configurations
```

Using nixos-rebuild directly:

```bash
# Build T470 configuration
sudo nixos-rebuild switch --flake .#nixos

# Build VM configuration
sudo nixos-rebuild switch --flake .#vm-headless

# Test without switching
sudo nixos-rebuild test --flake .#vm-headless
```

### Deploying to Remote VM

Using make targets:

```bash
# From repository root
make deploy-vm TARGET_HOST=user@vm-hostname

# From nixos directory
cd nixos
make deploy-vm TARGET_HOST=user@192.168.1.100
make remote/switch HOST=vm-headless TARGET_HOST=user@host
make remote/test TARGET_HOST=user@host    # Test first

# Build on remote server (faster for slow upload)
make deploy-vm TARGET_HOST=user@vm BUILD_HOST=user@vm
```

Manual deployment:

```bash
# Build locally and deploy to remote
nixos-rebuild switch --flake .#vm-headless \
  --target-host user@vm-hostname \
  --use-remote-sudo

# Or copy flake to VM and build there
rsync -avz nixos/ user@vm-hostname:~/nixos/
ssh user@vm-hostname
cd nixos && sudo nixos-rebuild switch --flake .#vm-headless
```

## Adding a New Machine

### 1. Define Machine in Chezmoi

Add to `.chezmoidata/machines.yaml`:

```yaml
machines:
  my-server:
    type: server
    hostname: my-server
    features:
      desktop: false
      audio: false
      # ... other features
```

### 2. Create NixOS Host Configuration

Create `nixos/hosts/my-server/configuration.nix`:

```nix
{ config, pkgs, lib, ... }:
{
  networking.hostName = "my-server";
  
  # Disable desktop
  custom.desktop.enable = false;
  
  # Server-specific configuration
  services.nginx.enable = true;
  # ...
}
```

### 3. Add to Flake

Update `nixos/flake.nix`:

```nix
nixosConfigurations = {
  # ... existing configs ...
  
  my-server = mkSystem {
    hostname = "my-server";
    system = "x86_64-linux";
    modules = [
      ./configuration.nix
      ./hosts/my-server/configuration.nix
    ];
  };
};
```

### 4. Initialize Machine

On the new machine:

```bash
# Clone dotfiles
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles

# Initialize chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply

# Deploy NixOS config
cd ~/.local/share/chezmoi/nixos
sudo nixos-rebuild switch --flake .#my-server
```

## Machine-Specific Configurations

### Desktop (T470)

- Full GNOME/Hyprland/LeftWM desktop
- Audio (PipeWire)
- Bluetooth
- KMonad keyboard remapping
- KDE Connect
- Power management (TLP)
- Desktop applications

### Headless VM

- SSH only (no password auth)
- Minimal packages
- No GUI services
- Smaller journal size
- Console on serial port
- Firewall (SSH only by default)

## Conditional Service Management

Services are conditionally enabled based on machine type:

| Service | T470 | VM | Controlled By |
| --- | --- | --- | --- |
| Desktop Environment | ✓ | ✗ | `custom.desktop.enable` |
| KMonad | ✓ | ✗ | Host config |
| SSH Server | ✓ | ✓ | Always enabled |
| Audio (PipeWire) | ✓ | ✗ | Host config |
| Bluetooth | ✓ | ✗ | Host config |
| Syncthing | ✓ | ✓ | User preference |

## Troubleshooting

### Chezmoi Not Detecting Machine Type

```bash
# Check hostname
hostname

# Verify machine data
chezmoi data | jq .machines

# Force re-read of templates
chezmoi init --force
```

### NixOS Build Fails

```bash
# Check flake syntax
nix flake check

# Show available configurations
nix flake show

# Build specific host
nix build .#nixosConfigurations.vm-headless.config.system.build.toplevel
```

### VM-Specific Issues

```bash
# If hardware-configuration.nix is missing on VM
sudo nixos-generate-config

# Serial console access
virsh console vm-name
```

## Best Practices

1. **Keep common config minimal**: Only truly universal settings in base `configuration.nix`
2. **Use options**: Create custom options (like `custom.desktop.enable`) for conditional features
3. **Test locally first**: Use `nixos-rebuild build` before deploying
4. **Document machine roles**: Keep `.chezmoidata/machines.yaml` updated
5. **Version control hardware configs**: But don't share between different hardware

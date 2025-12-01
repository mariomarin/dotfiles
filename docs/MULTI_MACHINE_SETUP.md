# Multi-Machine Configuration Guide

This repository supports managing configurations for multiple machines with different capabilities using Chezmoi
and platform-specific configuration tools (NixOS flakes, nix-darwin, winget).

## Naming Convention

All hosts use biology-themed names:

| Host | Type | Platform | Description |
|------|------|----------|-------------|
| **dendrite** | Laptop | NixOS | ThinkPad T470 portable workstation (branches like dendrites) |
| **mitosis** | VM | NixOS | Virtual machine for testing/replication (cell division) |
| **symbiont** | WSL | NixOS | NixOS on WSL (two systems coexisting) |
| **malus** | Desktop | macOS | macOS workstation (apple genus) |
| **prion** | Desktop | Windows | Native Windows workstation (self-replicating protein) |
| **spore** | Cloud | Windows | M365 DevBox cloud environment (dormant cell ready to grow) |

## Overview

The setup distinguishes between:

1. **Desktop systems**: Full GUI, audio, bluetooth (dendrite, malus, prion)
2. **Headless systems**: SSH/CLI-only, no GUI (mitosis, symbiont, spore)

## Chezmoi Configuration

### Machine Detection

Chezmoi detects machine type from the `HOSTNAME` environment variable, which must be set before running
`chezmoi init` or `chezmoi apply`:

```bash
# Set hostname (required before running chezmoi)
export HOSTNAME=dendrite  # Choose from: dendrite, malus, prion, symbiont, mitosis, spore
```

Machine configurations are defined in `.chezmoidata/machines.yaml`:

```yaml
# .chezmoidata/machines.yaml
machines:
  dendrite:
    type: laptop
    hostname: dendrite
    platform: nixos
    features:
      desktop: true
      kmonad: true

  mitosis:
    type: server
    hostname: mitosis
    platform: nixos
    features:
      desktop: false
      kmonad: false

  symbiont:
    type: wsl
    hostname: symbiont
    platform: nixos-wsl
    features:
      desktop: false
      wsl: true
```

**Important**: The `HOSTNAME` environment variable takes precedence over the system hostname. This allows
consistent configuration across different environments (e.g., WSL where system hostname might differ).

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
nix/
├── nixos/                 # NixOS configurations (Linux)
│   ├── flake.nix          # Multi-host flake definition
│   ├── configuration.nix  # Common configuration
│   ├── hosts/
│   │   ├── dendrite/      # ThinkPad T470 laptop
│   │   ├── mitosis/       # Virtual machine
│   │   └── symbiont/      # NixOS on WSL
│   └── modules/           # Shared NixOS modules
├── darwin/                # nix-darwin configurations (macOS)
│   ├── hosts/
│   │   └── malus/         # macOS workstation (planned)
│   └── modules/           # Shared darwin modules
└── windows/               # Windows configuration docs
    └── hosts/
        ├── prion/         # Native Windows (planned)
        └── spore/         # M365 DevBox (planned)
```

### Building for Different Hosts

Using just (recommended):

```bash
# From repository root
just nixos                      # Build current host's configuration

# From nix/nixos directory
cd nix/nixos
just switch                     # Build default (dendrite)
just switch HOST=mitosis        # Build mitosis config
just vm-switch                  # Shortcut for mitosis
just hosts                      # Show available configurations
```

Using nixos-rebuild directly (not recommended - use just instead):

```bash
# Build dendrite configuration
sudo nixos-rebuild switch --flake .#dendrite

# Build mitosis configuration
sudo nixos-rebuild switch --flake .#mitosis

# Build symbiont (WSL) configuration
sudo nixos-rebuild switch --flake .#symbiont

# Test without switching
sudo nixos-rebuild test --flake .#mitosis
```

**Recommended**: Use `just` commands which handle hostnames automatically and provide better UX.

### Deploying to Remote VM

Using just:

```bash
# From nix/nixos directory
cd nix/nixos
just deploy-vm TARGET_HOST=user@vm-hostname
just remote-switch TARGET_HOST=user@192.168.1.100 HOST=mitosis
just remote-test TARGET_HOST=user@host    # Test first

# Build on remote server (faster for slow upload)
just remote-switch TARGET_HOST=user@vm BUILD_HOST=user@vm
```

Manual deployment (not recommended - use just instead):

```bash
# Build locally and deploy to remote
nixos-rebuild switch --flake .#mitosis \
  --target-host user@vm-hostname \
  --use-remote-sudo

# Or copy flake to VM and build there
rsync -avz nix/nixos/ user@vm-hostname:~/nixos/
ssh user@vm-hostname
cd nixos && just nixos
```

**Recommended**: Use `just deploy-vm` or `just vm-switch` for better workflow.

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

Create `nix/nixos/hosts/myhost/configuration.nix`:

```nix
{ config, pkgs, lib, ... }:
{
  imports = [
    ../../common.nix
  ];

  networking.hostName = "myhost";

  # Disable desktop for headless
  custom.desktop.enable = false;

  # Enable minimal packages
  custom.minimal.enable = true;

  # Server-specific configuration
  services.nginx.enable = true;
  # ...
}
```

### 3. Add to Flake

Update `nix/nixos/flake.nix`:

```nix
nixosConfigurations = {
  dendrite = { ... };
  mitosis = { ... };
  symbiont = { ... };

  # New host
  myhost = mkSystem {
    hostname = "myhost";
    system = "x86_64-linux";
    modules = [
      ./configuration.nix
      ./hosts/myhost/configuration.nix
    ];
  };
};
```

### 4. Initialize Machine

On the new machine:

```bash
# Run bootstrap script (installs dependencies)
curl -sfL https://raw.githubusercontent.com/mariomarin/dotfiles/main/.install/bootstrap-unix.sh | bash

# Clone dotfiles
git clone https://github.com/yourusername/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi

# Enter nix-shell (provides chezmoi and tools)
nix-shell .install/shell.nix

# Set hostname (required)
export HOSTNAME=myhost

# Initialize chezmoi
chezmoi init --apply

# Unlock Bitwarden and apply with secrets
bw login
just bw-unlock
just apply

# Deploy NixOS config
cd nix/nixos
just switch HOST=myhost
```

## Machine-Specific Configurations

### dendrite (Desktop Laptop)

- Full GNOME/LeftWM desktop environment
- Audio (PipeWire)
- Bluetooth
- KMonad keyboard remapping
- KDE Connect
- Power management (TLP)
- Desktop applications

### mitosis (Headless VM)

- SSH only (no password auth)
- Minimal packages
- No GUI services
- Smaller journal size
- Console on serial port
- Firewall (SSH only by default)

### symbiont (WSL)

- NixOS on Windows Subsystem for Linux
- CLI-only (no GUI)
- Docker for containers
- Windows interop enabled
- Per-project devenv.nix

## Conditional Service Management

Services are conditionally enabled based on machine type:

| Service | dendrite | mitosis | symbiont | Controlled By |
|---------|----------|---------|----------|---------------|
| Desktop Environment | ✓ | ✗ | ✗ | `custom.desktop.enable` |
| KMonad | ✓ | ✗ | ✗ | Host config |
| SSH Server | ✓ | ✓ | ✓ | Always enabled |
| Audio (PipeWire) | ✓ | ✗ | ✗ | Host config |
| Bluetooth | ✓ | ✗ | ✗ | Host config |
| Docker | ✗ | ✓ | ✓ | Host config |
| Syncthing | ✓ | ✓ | Optional | User preference |

## Troubleshooting

### Chezmoi Not Detecting Machine Type

```bash
# Check HOSTNAME environment variable
echo $HOSTNAME

# If not set, export it
export HOSTNAME=dendrite  # Choose your machine name

# Verify machine data
chezmoi data | jq .machineConfig

# Check available machines
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

# Try building with just first
cd nix/nixos && just nixos

# Debug build specific host (advanced)
nix build .#nixosConfigurations.mitosis.config.system.build.toplevel
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

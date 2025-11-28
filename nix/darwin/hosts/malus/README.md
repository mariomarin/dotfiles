# malus - macOS Configuration

**Status**: Planned configuration for macOS using nix-darwin

## Overview

This is a placeholder for future macOS system configuration using nix-darwin. The name "malus" references the apple
genus, fitting the biology theme and macOS.

## Planned Features

- **Declarative macOS system management** via nix-darwin
- **GUI applications** from nixpkgs (firefox, alacritty, obsidian, etc.)
- **Homebrew fallback** for apps not in nixpkgs (Alfred, CleanShot)
- **System defaults** management for macOS preferences
- **Shared CLI tools** with NixOS configurations (git, neovim, tmux)
- **Development environment** with languages and build tools

## Integration Plan

This configuration will integrate with the unified flake structure:

```text
nix/
├── nixos/          # NixOS configurations
│   ├── flake.nix   # Main flake with both nixosConfigurations and darwinConfigurations
│   └── hosts/
│       ├── dendrite/    # Linux laptop
│       ├── mitosis/     # Linux VM
│       └── symbiont/    # Linux WSL
└── darwin/         # nix-darwin modules
    └── hosts/
        └── malus/       # macOS (this config)
```

## Setup Workflow

When implemented, the setup will be:

1. **Bootstrap**: `.bootstrap-unix.sh` installs:
   - Nix (Determinate Systems installer)
   - Bitwarden CLI via `nix profile install`

2. **First-time darwin setup**:

   ```bash
   cd ~/.local/share/chezmoi
   just darwin/first-time
   ```

3. **Future rebuilds**:

   ```bash
   just darwin
   ```

## Package Management Philosophy

**Priority order**:

1. **nixpkgs first** (both CLI and GUI apps)
2. **Homebrew casks** only when nixpkgs doesn't have it

Most GUI apps ARE in nixpkgs: firefox, discord, obsidian, alacritty, signal-desktop, vlc, etc.

## Configuration Structure (Planned)

```nix
# darwin/hosts/malus/configuration.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/packages.nix    # GUI and CLI packages from nixpkgs
    ../../modules/homebrew.nix    # Minimal homebrew casks
    ../../modules/system.nix      # macOS system defaults
  ];

  # Set hostname
  networking.hostName = "malus";
  networking.computerName = "malus";

  # System packages
  environment.systemPackages = with pkgs; [
    # ... packages
  ];

  # macOS system defaults
  system.defaults = {
    dock = {
      autohide = true;
      orientation = "bottom";
    };
    finder = {
      AppleShowAllExtensions = true;
    };
  };
}
```

## Related Documentation

- [darwin/README.md](../../README.md) - Darwin configuration overview
- [darwin/CLAUDE.md](../../CLAUDE.md) - AI guidance for darwin config
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/)

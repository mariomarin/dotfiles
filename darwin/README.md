# nix-darwin Configuration

This directory contains nix-darwin configuration for declarative macOS system management.

## Integration with Existing Flake

This darwin configuration integrates with the existing NixOS flake in `../nixos/flake.nix`.

**To integrate**: Add nix-darwin input and darwin configurations to `../nixos/flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # ... other inputs
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, ... }: {
    # Existing NixOS configurations
    nixosConfigurations = { ... };

    # Add darwin configurations
    darwinConfigurations = {
      "Marios-MacBook" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";  # or x86_64-darwin for Intel
        modules = [ ../darwin/hosts/macbook/configuration.nix ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
```

## Quick Start

### First-Time Setup

```bash
# 1. After running chezmoi apply, go to chezmoi source
cd ~/.local/share/chezmoi

# 2. Run first-time setup (installs nix-darwin)
just darwin/first-time

# 3. Future rebuilds
just darwin
```

### Common Commands

```bash
# Apply darwin configuration
just darwin

# Build without switching
just darwin/build

# Show available configurations
just darwin/hosts

# Health check
just darwin/health
```

## Directory Structure

```text
darwin/
├── README.md               # This file
├── justfile                # Darwin rebuild commands
├── hosts/                  # Host-specific configurations
│   └── macbook/            # MacBook configuration
│       └── configuration.nix
└── modules/                # Reusable darwin modules
    ├── packages.nix        # System packages
    ├── homebrew.nix        # Homebrew cask management (GUI apps only)
    └── system.nix          # macOS system settings
```

## Philosophy

- **Declarative**: All system configuration in Nix
- **Minimal Homebrew**: Only for GUI apps not in nixpkgs
- **Shared Packages**: CLI tools shared with NixOS configuration
- **macOS-Specific**: System preferences, defaults, services

## Key Differences from NixOS

- Uses `darwin-rebuild` instead of `nixos-rebuild`
- System configuration in `/etc/nix-darwin`
- Cannot manage kernel or boot loader
- macOS system preferences via `system.defaults`
- Homebrew casks for GUI apps (optional)

## Homebrew Integration

nix-darwin can manage Homebrew for GUI applications not available in nixpkgs:

```nix
homebrew = {
  enable = true;
  onActivation.cleanup = "zap";  # Uninstall unlisted packages

  # GUI applications only
  casks = [
    "visual-studio-code"
    "slack"
    "spotify"
  ];
};
```

**Philosophy**: Prefer nixpkgs when available, use Homebrew only for GUI apps.

## Platform Detection

Templates can detect macOS via:

- `{{ eq .chezmoi.os "darwin" }}`
- Host platform: `aarch64-darwin` or `x86_64-darwin`

## Related Documentation

- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/)
- [NixOS Darwin Options](https://daiderd.com/nix-darwin/manual/index.html#sec-options)
- [Root README](../README.md)

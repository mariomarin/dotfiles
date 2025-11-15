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

## Package Management

### GUI Applications

**Most GUI apps are available in nixpkgs!** Always check nixpkgs first:

```bash
# Search for an app
nix search nixpkgs firefox
nix search nixpkgs discord
```

**Install GUI apps via nixpkgs** (preferred):

```nix
# darwin/modules/packages.nix
environment.systemPackages = with pkgs; [
  firefox          # Web browser
  alacritty        # Terminal
  obsidian         # Notes
  discord          # Chat
  signal-desktop   # Messaging
  vlc              # Media player
];
```

### Homebrew Integration (Fallback)

Use Homebrew **only** for apps not in nixpkgs:

```nix
# darwin/modules/homebrew.nix
homebrew = {
  enable = true;
  onActivation.cleanup = "zap";  # Remove unlisted

  casks = [
    "alfred"       # Not in nixpkgs
    "cleanshot"    # Not in nixpkgs
  ];
};
```

**Rule**: Check `nix search nixpkgs` first. Only use Homebrew if the app isn't available.

## Platform Detection

Templates can detect macOS via:

- `{{ eq .chezmoi.os "darwin" }}`
- Host platform: `aarch64-darwin` or `x86_64-darwin`

## Related Documentation

- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/)
- [NixOS Darwin Options](https://daiderd.com/nix-darwin/manual/index.html#sec-options)
- [Root README](../README.md)

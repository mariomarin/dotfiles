# CLAUDE.md - nix-darwin Configuration

This file provides guidance to Claude Code when working with the nix-darwin configuration.

## Critical Information

**Integration Approach**: This darwin configuration shares a unified flake with NixOS configurations.

**Flake Location**: All configurations (NixOS + nix-darwin) are defined in `../flake.nix`

## First-Time Setup Workflow

When a user sets up macOS for the first time:

1. **Bootstrap** (`.bootstrap-unix.sh`) installs:
   - Nix via Determinate Systems installer (flakes enabled by default)
   - Bitwarden CLI via `nix profile install`

2. **First-time nix-darwin**:

   ```bash
   cd ~/.local/share/chezmoi
   just darwin/first-time
   ```

   This runs: `sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ..#HOSTNAME`

3. **Future rebuilds**:

   ```bash
   just darwin  # Uses darwin-rebuild (now in PATH)
   ```

## Flake Integration

The `../flake.nix` should contain both `nixosConfigurations` and `darwinConfigurations`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    # ... other inputs
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, ... }: {
    # NixOS configurations
    nixosConfigurations = {
      nixos = { ... };
      nixos-wsl = { ... };
    };

    # macOS configurations
    darwinConfigurations = {
      malus = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";  # or x86_64-darwin for Intel
        modules = [ ../darwin/hosts/malus/configuration.nix ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}
```

## Directory Structure

```text
darwin/
├── CLAUDE.md               # This file - AI guidance
├── README.md               # User-facing documentation
├── justfile                # Darwin rebuild commands
├── hosts/                  # Host-specific configurations
│   └── malus/              # macOS configuration (planned)
│       ├── README.md       # Host-specific docs
│       └── configuration.nix
└── modules/                # Reusable darwin modules
    ├── packages.nix        # CLI packages (shared with NixOS when possible)
    ├── homebrew.nix        # Homebrew casks (GUI apps only)
    ├── system.nix          # macOS system defaults
    └── services.nix        # macOS services (if needed)
```

## Key Concepts

### Package Management Philosophy

**Priority order for installing applications**:

1. **nixpkgs first** (CLI and GUI)
2. **Homebrew casks** only when nixpkgs doesn't have it or macOS integration is critical

**nixpkgs advantages**:

- Fully declarative and reproducible
- Automatic updates via `just darwin`
- Works across NixOS and macOS
- No separate package manager needed

**Use nixpkgs for**:

- CLI tools (git, neovim, tmux)
- Development tools
- **GUI applications** (firefox, alacritty, obsidian, discord, etc.)
- Anything available in nixpkgs

**Use Homebrew casks ONLY for**:

- Apps NOT in nixpkgs (check first: `nix search nixpkgs app-name`)
- Apps requiring tight macOS integration (Alfred, Bartender)
- Proprietary apps not in nixpkgs (Adobe Creative Cloud)

**Example**:

```nix
# darwin/modules/packages.nix - PREFERRED
environment.systemPackages = with pkgs; [
  # GUI apps from nixpkgs
  firefox
  alacritty
  obsidian
  discord
  # CLI tools
  git
  neovim
];

# darwin/modules/homebrew.nix - ONLY when nixpkgs doesn't have it
homebrew = {
  enable = true;
  onActivation.cleanup = "zap";

  casks = [
    "alfred"         # Not in nixpkgs
    "cleanshot"      # Not in nixpkgs
    # NOT: "firefox", "discord" - these ARE in nixpkgs!
  ];
};
```

### System Defaults

macOS system preferences are managed via `system.defaults`:

```nix
system.defaults = {
  dock = {
    autohide = true;
    orientation = "bottom";
    show-recents = false;
  };

  finder = {
    AppleShowAllExtensions = true;
    FXEnableExtensionChangeWarning = false;
  };

  NSGlobalDomain = {
    AppleShowAllExtensions = true;
    InitialKeyRepeat = 15;
    KeyRepeat = 2;
  };
};
```

### Platform Detection

Modules can detect macOS:

```nix
{ pkgs, lib, ...}:
{
  # macOS-specific config
  environment.systemPackages = with pkgs; [
    # ... packages
  ] ++ lib.optionals stdenv.isDarwin [
    # macOS-only packages
  ];
}
```

## Common Tasks

### Adding Packages

1. **For CLI tools**: Add to `darwin/modules/packages.nix`
2. **For GUI apps**: Add to `darwin/modules/homebrew.nix` casks
3. **Rebuild**: `just darwin`

### Modifying System Defaults

1. Edit `darwin/modules/system.nix`
2. Rebuild with `just darwin`
3. Changes apply immediately (no restart needed for most)

### Sharing Configuration with NixOS

**Best practice**: Put shared CLI tools in a common module that both NixOS and darwin import:

```nix
# nixos/modules/packages/cli-tools.nix
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    neovim
    tmux
    # ... shared CLI tools
  ];
}
```

Then import in both:

- `nixos/hosts/*/configuration.nix`
- `darwin/hosts/*/configuration.nix`

## Troubleshooting

### darwin-rebuild not found

**Problem**: After `just darwin/first-time`, `darwin-rebuild` not in PATH

**Solution**: Restart shell or run:

```bash
source /etc/static/bashrc  # or zshrc
```

### Homebrew conflicts

**Problem**: Homebrew package conflicts with Nix package

**Solution**:

1. Remove from Homebrew: `homebrew.casks` or `homebrew.brews`
2. Add to `darwin/modules/packages.nix` instead
3. Rebuild: `just darwin`

### System defaults not applying

**Problem**: Changed `system.defaults` but settings don't apply

**Solution**:

1. Rebuild: `just darwin`
2. Log out and log back in (for some settings)
3. Check System Preferences to verify

## Integration with Chezmoi

- Darwin configurations are managed by chezmoi
- Templates support `{{ eq .chezmoi.os "darwin" }}`
- Changes are tracked in git
- Apply with `chezmoi apply` then `just darwin`

## Best Practices

### Module Organization

- Keep modules focused and single-purpose
- Share common CLI tools with NixOS
- Document macOS-specific settings
- Use comments to explain non-obvious defaults

### Homebrew Usage

- Minimize Homebrew casks
- Document why each cask is needed
- Prefer nixpkgs when available
- Use `onActivation.cleanup = "zap"` to remove unlisted

### Testing Changes

- Use `just darwin/build` to test without switching
- Test on a non-production machine first
- Document breaking changes

## Related Documentation

- [darwin/README.md](./README.md) - User-facing documentation
- [Root CLAUDE.md](../CLAUDE.md) - Repository overview
- [nixos/CLAUDE.md](../nixos/CLAUDE.md) - NixOS configuration guidance
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/)

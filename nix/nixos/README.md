# NixOS Configuration

Declarative NixOS configuration managed with chezmoi, supporting multiple hosts with shared and host-specific configurations.

## Quick Start

```bash
# Rebuild system configuration
sudo nixos-rebuild switch --flake .#$(hostname)

# Or use the Makefile
make switch
```

## Architecture

### Multi-Host Support

The configuration supports three host types:

- **dendrite**: ThinkPad T470 portable workstation with GNOME/LeftWM
- **mitosis**: Virtual machine for testing and replication
- **symbiont**: NixOS on WSL (two systems coexisting) for development

### Package Organization

Packages are organized into four tiers for maintainability and reusability:

#### 1. Minimal (`modules/minimal.nix`)

Essential CLI tools and utilities for **all hosts** (headless and desktop).

- Core utilities: vim, git, tmux, bash, curl, wget, rsync
- Development tools: fzf, gh, age, jq
- System utilities: atuin, topgrade, bitwarden-cli
- Modern CLI replacements (optional via `modernCli = true`): bat, eza, ripgrep, fd, delta, lazygit,
  difftastic, dua, lsd, procs, sd, xcp, zoxide

#### 2. Development (`modules/development.nix`)

Development languages, build tools, and environments for coding workstations.

- Nix tooling: chezmoi, direnv, niv, nix-direnv, devenv
- Languages: go, lua, nodejs, openjdk, rustup
- Build tools: bear, clang, gnumake, pkg-config
- Dev utilities: dive, nil, pandoc, poetry, sqlite, zeal
- Editor: neovim
- AI assistant: claude-code

#### 3. Desktop (`modules/desktop-packages.nix`)

GUI applications and desktop-only utilities.

- Applications: alacritty, brave, firefox, obsidian, gimp
- Window manager: leftwm, rofi, polybar, dunst
- Desktop tools: syncthing, bitwarden-desktop
- Multimedia: feh, pavucontrol, playerctl

#### 4. Specialized (`modules/packages/additional-tools.nix`)

Domain-specific tools for specialized workflows.

- Kubernetes: kubectl, krew, stern
- Cloud: awscli, aws-sso-cli, rclone
- Media: yewtube, yt-dlp
- Git utilities: git-branchless, git-sizer, bfg-repo-cleaner
- Data: xan, jd-diff-patch
- Search: meilisearch

### Configuration Hierarchy

```text
common.nix (universal settings)
    ↓
configuration.nix (module imports)
    ↓
hosts/*/configuration.nix (host-specific)
```

Each host:

1. Imports `common.nix` for universal settings (state version, nix config, GC)
2. Sets its own hostname
3. Enables appropriate modules (minimal, development, desktop, wsl)
4. Imports hardware configuration (except WSL)

## Adding Packages

Choose the appropriate module based on package purpose:

| Package Type | Module | Example |
|-------------|--------|---------|
| CLI tool for all hosts | `modules/minimal.nix` | ripgrep, jq, curl |
| Development tool | `modules/development.nix` | nodejs, clang, poetry |
| GUI application | `modules/desktop-packages.nix` | firefox, gimp |
| Specialized tool | `modules/packages/additional-tools.nix` | kubectl, meilisearch |

Then:

1. Edit the appropriate module file
2. Add package to `environment.systemPackages`
3. Rebuild: `sudo nixos-rebuild switch`

## Host Configurations

### dendrite (ThinkPad T470 Portable Workstation)

- Modules: minimal, development, desktop
- Desktop: LeftWM tiling window manager
- Features: Full development environment with GUI tools

### symbiont (Headless)

- Modules: minimal, development, wsl
- Purpose: Development via browser (MS DevBox)
- Features: CLI-only, Docker enabled, per-project devenv.nix

### mitosis (Virtual Machine)

- Modules: minimal
- Purpose: Testing, replication, and experimentation
- Features: Minimal footprint, SSH-only access

## Module System

### Core Modules

- `boot.nix`: Boot loader (conditional, not for WSL)
- `networking.nix`: Network configuration (conditional, not for WSL)
- `locale.nix`: Localization and timezone
- `users.nix`: User account management
- `security.nix`: Security settings, gnome-keyring
- `services.nix`: System services
- `virtualization.nix`: Docker, containers

### Optional Modules

- `wsl.nix`: WSL-specific configuration
- `desktop.nix`: Desktop environment (GNOME/LeftWM)

## Flake Structure

The configuration uses Nix flakes for reproducible builds:

```nix
inputs:
  - nixpkgs (stable)
  - nixpkgs-unstable
  - nixos-wsl
  - home-manager

outputs:
  - dendrite: ThinkPad T470 portable workstation
  - mitosis: Virtual machine for testing and replication
  - symbiont: NixOS on WSL (two systems coexisting)
```

## Best Practices

### Package Placement

- **Don't duplicate**: Check existing modules before adding packages
- **Think globally**: If a CLI tool is useful everywhere, put it in minimal.nix
- **Separation**: Keep GUI apps separate from CLI tools
- **Development**: Language tools go in development.nix, not per-language modules

### Module Descriptions

- Each module has a header comment describing its purpose
- Focus on roles, not specific package lists (they change frequently)
- Update CLAUDE.md when adding new modules

### Commits

- Keep commits focused and granular
- Avoid listing every package in commit messages
- Focus on the "why" rather than the "what"

## Documentation

- `README.md` (this file): Human-readable overview and guide
- `CLAUDE.md`: Instructions for Claude Code AI assistant
- `hosts/*/README.md`: Host-specific documentation

## Common Operations

```bash
# Switch to new configuration
sudo nixos-rebuild switch

# Test without activation
sudo nixos-rebuild test

# Build without activation
sudo nixos-rebuild build

# Update flake inputs
nix flake update

# Check what will change
nix flake check

# Apply chezmoi changes
chezmoi apply -v
```

## Troubleshooting

### Build fails with "option does not exist"

- Check if conditional modules are properly configured
- Verify host-specific settings in `hosts/*/configuration.nix`

### Package conflicts

- Check for duplicates across modules with `rg "package-name"`
- Remove from the less appropriate module

### WSL-specific issues

- Ensure `custom.wsl.enable = true` in WSL host config
- Check that boot and networking modules are disabled

## References

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [NixOS WSL](https://github.com/nix-community/NixOS-WSL)

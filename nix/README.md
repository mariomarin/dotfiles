# Nix System Configurations

This directory contains all Nix-based system configurations for declarative system management across platforms.

## Structure

```text
nix/
├── flake.nix           # Unified flake for all platforms (to be created)
├── flake.lock          # Locked dependencies
├── nixos/              # NixOS configurations (Linux)
│   ├── README.md
│   ├── CLAUDE.md
│   ├── justfile
│   ├── hosts/          # Per-host configurations
│   └── modules/        # Reusable NixOS modules
├── darwin/             # nix-darwin configurations (macOS)
│   ├── README.md
│   ├── CLAUDE.md
│   ├── justfile
│   ├── hosts/          # Per-host configurations
│   └── modules/        # Reusable darwin modules
└── windows/            # Windows configuration docs (not Nix-based)
    ├── README.md
    └── hosts/          # Host-specific documentation
```

## Unified Flake

All platforms share a single `flake.nix` that defines:

- **nixosConfigurations**: Linux systems (NixOS, WSL)
- **darwinConfigurations**: macOS systems (nix-darwin)

This allows sharing common modules and maintaining consistent package versions across platforms.

## Host Configurations

### NixOS Hosts (Linux)

- **dendrite**: ThinkPad T470 portable workstation with GNOME/LeftWM
- **mitosis**: Virtual machine for testing and replication
- **symbiont**: NixOS on WSL (two systems coexisting) for development

### Darwin Hosts (macOS)

- **malus**: macOS configuration (planned) - biology theme: Malus (apple genus)

### Windows Hosts

- **prion**: Native Windows workstation (planned)
- **spore**: Microsoft 365 DevBox cloud Windows environment (planned)

## Platform-Specific Documentation

- **NixOS**: See [nixos/README.md](nixos/README.md) for Linux system management
- **macOS**: See [darwin/README.md](darwin/README.md) for macOS system management

## Common Commands

### NixOS (Linux)

```bash
# From repository root
just nixos              # Rebuild system (alias)
just nix/nixos/switch   # Full path
just nix/nixos/health   # Health check
```

### nix-darwin (macOS)

```bash
# From repository root
just darwin              # Rebuild system (alias)
just nix/darwin/switch   # Full path
just nix/darwin/health   # Health check
```

## Philosophy

- **Declarative**: All system configuration in Nix
- **Reproducible**: Same config = same system
- **Platform-Agnostic**: Share what makes sense, specialize what doesn't
- **Version Controlled**: Managed through chezmoi with git

## Integration with Chezmoi

- Nix configurations are managed by chezmoi
- Apply changes: `chezmoi apply` then rebuild with `just`
- Templates can detect platform: `{{ eq .chezmoi.os "darwin" }}`

## Related Documentation

- [Root README](../README.md) - Repository overview
- [Root CLAUDE.md](../CLAUDE.md) - AI guidance for the repository

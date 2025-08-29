# CLAUDE.md - NixOS Configuration

This file provides guidance to Claude Code when working with the NixOS configuration.

## Directory Structure

```
nixos/
├── flake.nix                 # Nix flakes configuration
├── flake.lock                # Locked flake dependencies
├── configuration.nix         # Main NixOS configuration
├── hardware-configuration.nix # Hardware-specific settings
├── rebuild-flake.sh          # Helper script for rebuilding with flakes
└── modules/                  # Modular configuration
    ├── boot.nix             # Boot loader configuration
    ├── desktop.nix          # Desktop environment setup
    ├── desktop/
    │   ├── gnome.nix       # GNOME desktop configuration
    │   └── hyprland.nix    # Hyprland compositor configuration
    ├── development/
    │   ├── go.nix          # Go development environment
    │   ├── node.nix        # Node.js development environment
    │   ├── python.nix      # Python development environment
    │   └── rust.nix        # Rust development environment
    ├── locale.nix          # Localization settings
    ├── networking.nix      # Network configuration
    ├── packages.nix        # System-wide packages
    ├── security.nix        # Security settings
    ├── services.nix        # System services
    ├── services/
    │   ├── docker.nix      # Docker configuration
    │   └── syncthing.nix   # Syncthing service
    ├── system/
    │   └── fonts.nix       # Font configuration
    ├── users.nix           # User accounts
    ├── users/
    │   └── mario.nix       # User-specific configuration
    └── virtualization.nix  # Virtualization settings
```

## Configuration Philosophy

- **Modular Design**: Each aspect of the system is in its own module
- **Declarative**: All system configuration is declared in Nix
- **Reproducible**: Same configuration produces identical systems
- **Version Controlled**: Managed through chezmoi with git

## Key Components

### System Configuration
- **State Version**: 24.11 (NixOS version)
- **Nix Features**: Flakes and nix-command enabled
- **Garbage Collection**: Weekly, removes derivations older than 15 days

### Desktop Environment
- Primary: GNOME or Hyprland (configurable)
- Display Manager: GDM
- Window Management: Mutter (GNOME) or Hyprland

### Development Tools
- **Languages**: Go, Python, Rust, Node.js
- **Editors**: Neovim (with LazyVim)
- **Containers**: Docker, Podman
- **Version Control**: Git with delta diff viewer

### Package Management
- **System Packages**: Defined in `modules/packages.nix`
- **Development Tools**: Language-specific modules
- **Unfree Software**: Allowed (for proprietary tools)

## Common Tasks

### Adding System Packages
1. Edit `modules/packages.nix`
2. Add package to `environment.systemPackages`
3. Rebuild with `sudo nixos-rebuild switch`

### Enabling Services
1. Create or edit service module in `modules/services/`
2. Import in `modules/services.nix`
3. Configure service options
4. Rebuild system

### User Configuration
1. Edit `modules/users/mario.nix` for user-specific settings
2. Update `modules/users.nix` for system-wide user settings
3. Rebuild to apply changes

## NixOS Commands (Flakes)

```bash
# Rebuild system configuration with flakes
sudo nixos-rebuild switch --flake /home/mario/.local/share/chezmoi/nixos#nixos

# Or use the helper script
./nixos/rebuild-flake.sh switch

# Test configuration without switching
./nixos/rebuild-flake.sh test

# Build configuration without activating
./nixos/rebuild-flake.sh build

# Update flake inputs
nix flake update

# Show flake metadata
nix flake show

# Garbage collection
sudo nix-collect-garbage -d

# Search for packages
nix search nixpkgs <package-name>
```

## Flake Configuration

The system now uses Nix Flakes for:
- **Reproducible builds**: All dependencies are locked in `flake.lock`
- **Better dependency management**: Explicit input declarations
- **Hardware optimizations**: Using nixos-hardware for ThinkPad T470
- **Mixed stable/unstable**: Stable base with unstable packages available

## Integration with Chezmoi

- Configuration files are managed by chezmoi
- Templates support machine-specific variations
- Changes are tracked in git
- Apply with `chezmoi apply` then rebuild NixOS

## Important Notes

- Always test configuration before switching
- Keep hardware-configuration.nix machine-specific
- Document any non-standard configurations
- Use modules for better organization
- Prefer declarative configuration over imperative

## Troubleshooting

### Common Issues
1. **Build Failures**: Check syntax with `nix-instantiate --parse`
2. **Missing Packages**: Ensure correct channel is configured
3. **Service Conflicts**: Review systemd service dependencies
4. **Hardware Issues**: Verify hardware-configuration.nix

### Debug Commands
```bash
# Check configuration syntax
nix-instantiate --parse configuration.nix

# View system journal
journalctl -xe

# Check service status
systemctl status <service>

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## Related Documentation

- [Root CLAUDE.md](../CLAUDE.md)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [NixOS Wiki](https://nixos.wiki/)
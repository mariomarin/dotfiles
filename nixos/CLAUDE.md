# CLAUDE.md - NixOS Configuration

This file provides guidance to Claude Code when working with the NixOS configuration.

## Directory Structure

```text
nixos/
├── Makefile                     # NixOS rebuild commands
├── flake.nix                    # Nix flakes configuration
├── flake.lock                   # Locked flake dependencies
├── common.nix                   # Universal settings for all hosts
├── configuration.nix            # Module imports
├── hosts/                       # Host-specific configurations
│   ├── t470/                    # ThinkPad T470 (desktop)
│   ├── vm/                      # Virtual machine
│   └── wsl/                     # WSL (headless)
└── modules/                     # Modular configuration
    ├── minimal.nix              # Essential CLI tools for all hosts
    ├── development.nix          # Development tools and environment
    ├── desktop-packages.nix     # Desktop GUI applications
    ├── boot.nix                 # Boot loader configuration
    ├── wsl.nix                  # WSL-specific configuration
    ├── desktop.nix              # Desktop environment setup
    ├── locale.nix               # Localization settings
    ├── networking.nix           # Network configuration
    ├── security.nix             # Security settings
    ├── services.nix             # System services
    ├── users.nix                # User accounts
    ├── virtualization.nix       # Virtualization settings
    ├── packages/                # Specialized package collections
    │   └── additional-tools.nix # Domain-specific tools
    └── system/
        └── fonts.nix            # Font configuration
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

Packages are organized into three tiers:
- **Minimal** (`modules/minimal.nix`): Essential CLI tools for all hosts (headless and desktop)
  - Includes optional modern CLI replacements when `modernCli = true`
- **Development** (`modules/development.nix`): Development tools and environments
  - Enabled on developer workstations (t470, wsl)
- **Desktop** (`modules/desktop-packages.nix`): GUI applications and desktop-only utilities
  - Only enabled on desktop hosts (t470)
- **Specialized** (`modules/packages/additional-tools.nix`): Domain-specific tools (Kubernetes, cloud, etc.)

**Unfree Software**: Allowed for proprietary tools

## Common Tasks

### Adding Packages

Choose the appropriate module based on the package type:
- **CLI tools** for all hosts → `modules/minimal.nix`
- **Development tools** → `modules/development.nix`
- **GUI applications** → `modules/desktop-packages.nix`
- **Specialized tools** (K8s, cloud, etc.) → `modules/packages/additional-tools.nix`

Then:
1. Edit the appropriate module file
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
# From the nixos directory:
cd nixos

# Rebuild system configuration
make switch  # or just 'make'

# Test configuration without switching
make test

# Update boot configuration (apply on next boot)
make boot

# Build configuration without activating
make build

# Update flake inputs
make update

# Check flake configuration
make check

# Show flake metadata
make show

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

## User Services

This repository uses two approaches for systemd user services:

1. **NixOS modules** (in `modules/services.nix`) for system-wide services
2. **Chezmoi scripts** for user-specific services

See [../docs/USER_SERVICES.md](../docs/USER_SERVICES.md) for detailed guidelines.

## WSL Support

This repository supports NixOS on Windows Subsystem for Linux (WSL2) via the NixOS-WSL project.

### WSL Configuration

- **Host**: `nixos-wsl`
- **Type**: Headless, CLI-only (no GUI)
- **Use Case**: Development via browser (MS DevBox) or SSH
- **Philosophy**: Minimal system packages, per-project tooling via `devenv.nix`

### WSL-Specific Features

✅ **Enabled:**
- Full NixOS with flakes and systemd
- Windows interop (run `.exe` from Linux)
- Docker for containers
- SSH server
- Core CLI tools only

❌ **Disabled:**
- All GUI applications
- Desktop environment and X11
- Audio services (use Windows audio)
- Hardware-specific services (Bluetooth, TLP, KMonad)
- NetworkManager (uses WSL networking)

### Building WSL Configuration

```bash
# From any NixOS system (test build)
cd nixos
nix build .#nixosConfigurations.nixos-wsl.config.system.build.toplevel

# On WSL (apply configuration)
sudo nixos-rebuild switch --flake /etc/nixos#nixos-wsl

# Update flake inputs
nix flake update
```

### WSL Detection

Chezmoi automatically detects WSL via `$WSL_DISTRO_NAME`:
- Machine type: `"wsl"`
- Features: `wsl = true`, `desktop = false`, `audio = false`

### Development Workflow

System packages are minimal. Use `devenv.nix` per repository:

```bash
cd /path/to/project
devenv shell  # If project has devenv.nix

# Or with direnv
echo "use devenv" > .envrc
direnv allow
```

### WSL Limitations

- No boot loader or kernel configuration
- No hardware-specific services
- No NetworkManager (uses WSL networking)
- No GUI (pure CLI/TUI workflow)

For detailed WSL documentation, see [hosts/wsl/README.md](hosts/wsl/README.md).

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
5. **SSH Agent Connection Refused**: See SSH Agent Configuration section below

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

## SSH Agent Configuration

### Issue: GNOME Keyring SSH Component Not Starting

The system is configured to use GNOME Keyring as the SSH agent, but the SSH component may not start properly.

#### Configuration Files

- `modules/security.nix`: Disables standard SSH agent (`programs.ssh.startAgent = false`)
- `modules/desktop.nix`: Contains session commands to start GNOME keyring with SSH

#### Problem

GNOME keyring daemon starts with only the `secrets` component, missing the SSH component:

```text
gnome-keyring-daemon --start --foreground --components=secrets
```

The session startup command should start it with SSH support, but fails if daemon is already running.

#### Solutions

1. **Temporary Fix - Kill and Restart GNOME Keyring**:

   ```bash
   pkill gnome-keyring-daemon
   eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
   export SSH_AUTH_SOCK
   ssh-add ~/.ssh/id_ed25519
   ```

2. **Use Systemd SSH Agent Instead**:

   ```bash
   export SSH_AUTH_SOCK=/run/user/1000/ssh-agent.socket
   ssh-add ~/.ssh/id_ed25519
   ```

3. **Permanent Fix - Re-enable Standard SSH Agent**:
   Edit `modules/security.nix` and change:

   ```nix
   programs.ssh.startAgent = true;  # was false
   ```

   Then rebuild: `sudo nixos-rebuild switch`

#### Environment Variables

When working correctly, you should have:

- `SSH_AUTH_SOCK` pointing to either:
  - `/run/user/1000/keyring/ssh` (GNOME keyring)
  - `/run/user/1000/ssh-agent.socket` (systemd SSH agent)

## Related Documentation

- [Root CLAUDE.md](../CLAUDE.md)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [NixOS Wiki](https://nixos.wiki/)

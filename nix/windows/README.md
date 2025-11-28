# Windows System Configuration

This directory contains Windows system configuration documentation. Unlike NixOS and nix-darwin, Windows systems
don't use Nix but are managed through native Windows package managers and chezmoi.

## Configuration Approach

Windows configuration is managed through:

1. **Package Declarations**: `.chezmoidata/packages.yaml` defines packages
2. **Chezmoi Scripts**: `run_onchange_` scripts install packages via winget/scoop
3. **Dotfile Management**: Chezmoi templates for Windows-specific configs
4. **Bootstrap**: `.bootstrap-windows.ps1` installs initial tools

## Directory Structure

```text
windows/
├── README.md               # This file
└── hosts/                  # Host-specific configurations
    └── prion/              # Windows configuration (planned)
        └── README.md       # Host-specific documentation
```

## Why Not Nix on Windows?

While Nix can technically run on Windows (via WSL), native Windows systems are better managed with:

- **winget**: Official Microsoft package manager, best Windows integration
- **scoop**: Alternative for developer tools and portable apps
- **Chezmoi**: Dotfile management with templates

This approach:

- Works with native Windows tools
- Doesn't require WSL or complex setup
- Integrates with Windows Update and Microsoft Store
- Provides declarative package management via chezmoi scripts

## Hosts

### prion (Planned)

Native Windows workstation using winget/scoop for package management. See [hosts/prion/README.md](hosts/prion/README.md)
for details.

## Package Management

Packages are defined declaratively in `.chezmoidata/packages.yaml`:

```yaml
packages:
  windows:
    winget:
      - Git.Git
      - Neovim.Neovim
      # ... more packages
```

Installed automatically via chezmoi scripts when the package list changes.

## Related Documentation

- [Root README](../../README.md) - Repository overview
- [WSL Configuration](../nixos/hosts/symbiont/README.md) - For NixOS on WSL
- [winget documentation](https://learn.microsoft.com/en-us/windows/package-manager/winget/)

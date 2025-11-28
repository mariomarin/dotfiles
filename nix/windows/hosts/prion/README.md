# prion - Windows Configuration

**Status**: Planned configuration for Windows

## Overview

Placeholder for future Windows system configuration using winget and chezmoi. Biology theme: Prion (self-replicating
protein).

## Planned Package Management

Unlike NixOS and nix-darwin, Windows configuration will use native Windows package managers:

### Primary Tools

- **winget**: Windows Package Manager (official Microsoft tool)
  - CLI and GUI applications
  - System-wide installation
  - Declarative via `.chezmoidata/packages.yaml`

- **scoop**: Alternative package manager (fallback)
  - Apps not in winget
  - Portable installations
  - Developer-focused tools

### Declarative Configuration

Packages defined in `.chezmoidata/packages.yaml`:

```yaml
packages:
  windows:
    winget:
      - Git.Git
      - Neovim.Neovim
      - direnv.direnv
      - casey.just
      - Alacritty.Alacritty
      - Microsoft.PowerShell
    scoop:
      # Apps not in winget
```

Installed via chezmoi script:

```powershell
# .chezmoiscripts/run_onchange_windows-install-packages.ps1.tmpl
# Reads packages.yaml and installs via winget
```

## Integration with Chezmoi

Chezmoi will manage:

- PowerShell profile configuration
- Windows Terminal settings
- Application dotfiles (Alacritty, etc.)
- Package declarations in `packages.yaml`
- Bootstrap scripts (`.bootstrap-windows.ps1`)

## Planned Features

- **Declarative package management** via winget/scoop
- **PowerShell configuration** with custom modules
- **Windows Terminal** settings and themes
- **Development environment** with languages and build tools
- **Shared CLI tools** where possible (git, neovim, just, etc.)

## Configuration Approach

Unlike Nix systems, Windows configuration focuses on:

1. **Bootstrap phase**: Install winget, PowerShell 7
2. **Package installation**: Declarative via `packages.yaml` + chezmoi scripts
3. **Dotfile management**: Chezmoi templates for Windows-specific configs
4. **Registry settings**: Via PowerShell scripts (if needed)

## Example Structure

```powershell
# PowerShell profile (~/.config/powershell/Microsoft.PowerShell_profile.ps1)
# Managed by chezmoi

# Windows Terminal settings
# ~/.config/windows-terminal/settings.json

# Package declarations
# .chezmoidata/packages.yaml
```

## Differences from Nix Systems

| Aspect | NixOS/darwin | Windows |
|--------|--------------|---------|
| Package Manager | Nix | winget/scoop |
| Config Tool | nix-rebuild | chezmoi only |
| System Settings | Nix modules | PowerShell/Registry |
| Declarative | Fully | Package list only |
| Rollback | Built-in | Manual via winget |

## Related Documentation

- [Root README](../../../../README.md) - Repository overview
- [Bootstrap documentation](../../../../docs/) - Windows bootstrap process
- [winget documentation](https://learn.microsoft.com/en-us/windows/package-manager/winget/)

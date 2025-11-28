# spore - Microsoft 365 DevBox Configuration

**Status**: Planned configuration for Microsoft 365 Developer Box (Windows)

## Overview

Placeholder for cloud-based Windows development environment on Microsoft 365 DevBox. Biology theme: Spore (dormant cell
ready to grow in new environment).

## Microsoft 365 DevBox

DevBox provides:

- **Cloud-hosted Windows 11** Pro VM in Azure
- **Browser-based access** via Remote Desktop
- **Managed by Microsoft**: Infrastructure, updates, security
- **Integration**: Microsoft 365 services, Azure resources
- **Self-service**: Developers can provision their own boxes

## Planned Configuration

### Package Management

Same approach as prion (native Windows):

```yaml
# .chezmoidata/packages.yaml
packages:
  windows:
    winget:
      - Git.Git
      - Neovim.Neovim
      - Microsoft.PowerShell
      - Alacritty.Alacritty
      # Cloud dev tools
      - Microsoft.AzureCLI
```

### Configuration Approach

1. **Bootstrap**: `.bootstrap-windows.ps1` installs winget, PowerShell 7
2. **Packages**: Declarative via `packages.yaml` + chezmoi scripts
3. **Dotfiles**: Chezmoi templates for Windows-specific configs
4. **Cloud integration**: Azure CLI, Microsoft Graph API

## Differences from Other Windows Hosts

| Feature | spore (DevBox) | prion (Native Windows) |
|---------|----------------|------------------------|
| Platform | Cloud VM | Physical/local VM |
| Access | Browser RDP | Direct |
| Management | Microsoft-managed | Self-managed |
| Storage | Cloud (limited) | Local disk |
| Purpose | Cloud development | Local development |
| Cost | Per-hour Azure | One-time hardware |

## DevBox-Specific Optimizations

- **Minimal local storage**: Keep large files in Azure Storage
- **Ephemeral workspace**: Treat as disposable, config in chezmoi
- **Cloud-native tools**: Azure CLI, GitHub CLI, cloud IDEs
- **Remote development**: VSCode Remote, browser-based editors

## Integration with Microsoft 365

- **Microsoft Graph API**: Access M365 data
- **Azure Active Directory**: SSO authentication
- **Azure DevOps**: CI/CD pipelines
- **GitHub**: Codespaces integration

## Configuration Files

```powershell
# PowerShell profile
~/.config/powershell/Microsoft.PowerShell_profile.ps1

# Windows Terminal
~/.config/windows-terminal/settings.json

# Git config
~/.gitconfig

# Package declarations
.chezmoidata/packages.yaml
```

## Related Documentation

- [prion README](../prion/README.md) - Similar Windows configuration
- [windows/README.md](../../README.md) - Windows configuration overview
- [Microsoft DevBox docs](https://learn.microsoft.com/en-us/microsoft-365/dev-box/)

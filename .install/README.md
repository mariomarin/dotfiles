# Installation Scripts

Bootstrap scripts for setting up dotfiles on new machines.

## Windows Setup

PowerShell **does NOT** natively support Makefiles. Use the PowerShell setup script instead.

### Remote Installation (Recommended)

```powershell
# Run as Administrator
irm https://raw.githubusercontent.com/mariomarin/dotfiles/main/.install/windows-setup.ps1 | iex
```

### Local Installation

```powershell
# Run as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
.\windows-setup.ps1
```

### What it installs

- **Git** - Version control
- **chezmoi** - Dotfiles manager
- **Bitwarden CLI** - Password manager
- **Alacritty** - Terminal emulator

### After Installation

1. Close and reopen PowerShell (to refresh PATH)
2. Initialize chezmoi:

   ```powershell
   chezmoi init https://github.com/mariomarin/dotfiles.git
   ```

3. Review and apply:

   ```powershell
   chezmoi diff
   chezmoi apply -v
   ```

## Linux/NixOS Setup

On NixOS, the system packages are managed via the flake configuration.

### Fresh NixOS Install

1. Clone the repository:

   ```bash
   nix-shell -p git
   git clone https://github.com/mariomarin/dotfiles.git ~/.local/share/chezmoi
   ```

2. Apply NixOS configuration:

   ```bash
   cd ~/.local/share/chezmoi/nixos
   sudo nixos-rebuild switch --flake .#nixos
   ```

3. The NixOS configuration installs chezmoi, so now apply dotfiles:

   ```bash
   chezmoi init
   chezmoi apply -v
   ```

### WSL (Windows Subsystem for Linux)

1. Install WSL2 with NixOS (see [NixOS-WSL](https://github.com/nix-community/NixOS-WSL))

2. Follow the NixOS setup above, using the WSL host configuration:

   ```bash
   cd ~/.local/share/chezmoi/nixos
   sudo nixos-rebuild switch --flake .#nixos-wsl
   ```

## Alternative: Manual Installation

If you prefer to install tools manually:

### Windows (via winget)

```powershell
winget install Git.Git
winget install twpayne.chezmoi
winget install Bitwarden.CLI
winget install Alacritty.Alacritty
```

### macOS (via Homebrew)

```bash
brew install git chezmoi bitwarden-cli alacritty
```

### Linux (varies by distro)

See [chezmoi installation guide](https://www.chezmoi.io/install/)

## Makefile vs PowerShell

**Question**: Can Windows PowerShell run Makefiles?

**Answer**: No, PowerShell does not natively support Makefiles. Options:

1. **Use PowerShell scripts** (this approach) - Native Windows solution
2. **Install WSL** - Run Linux/NixOS in WSL and use Makefiles there
3. **Install GNU Make for Windows** - Via Chocolatey, Scoop, or MinGW
4. **Use justfile** - Cross-platform alternative to Make (already in minimal.nix)

This repository uses **PowerShell scripts for Windows** and **Makefiles for Linux/NixOS**.

## Repository Structure

```text
.install/
├── README.md              # This file
└── windows-setup.ps1      # Windows bootstrap script
```

## Troubleshooting

### Windows: Execution Policy Error

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

### Windows: winget not found

Install "App Installer" from Microsoft Store.

### chezmoi: "source directory does not exist"

```bash
chezmoi init https://github.com/mariomarin/dotfiles.git
```

## Security Note

Always review scripts before running them, especially with `irm | iex` or `curl | sh` patterns.

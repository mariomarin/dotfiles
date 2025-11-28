# Installation Scripts

Bootstrap scripts for setting up dotfiles on new machines.

## Bootstrap Philosophy

**Bootstrap scripts install ONLY what chezmoi templates need to render:**

- **Bitwarden CLI** - Required for `{{ bitwarden ... }}` template functions
- Platform-specific package managers (Homebrew on macOS, Nix for nix-darwin)

**Everything else** is installed declaratively via:

- NixOS: `configuration.nix` and `nixos-rebuild`
- macOS: nix-darwin or Homebrew packages in `.chezmoidata/packages.yaml`
- Windows: winget packages in `.chezmoidata/packages.yaml`

## Windows Setup

### Prerequisites (Windows)

Install Git and chezmoi manually:

```powershell
# Required to initialize dotfiles
winget install Git.Git
winget install twpayne.chezmoi
```

### Setup Steps (Windows)

```powershell
# Clone dotfiles
chezmoi init https://github.com/mariomarin/dotfiles.git

# Preview changes
chezmoi diff

# Apply configuration (runs .bootstrap-windows.ps1 automatically)
chezmoi apply -v
```

### What Happens on Bootstrap (Windows)

The `.bootstrap-windows.ps1` pre-hook installs:

- **Bitwarden CLI** via winget (for secret management in templates)

Additional packages are installed via `run_onchange_` scripts based on `.chezmoidata/packages.yaml`.

## NixOS Setup

**NixOS packages are managed declaratively** - bootstrap does minimal work.

### Prerequisites (NixOS)

Install Bitwarden CLI system-wide (required for chezmoi templates):

```bash
# Add to your configuration.nix temporarily, or use nix-env
nix-env -iA nixos.bitwarden-cli
```

### Fresh NixOS Install

1. Clone the repository:

   ```bash
   nix-shell -p git chezmoi
   git clone https://github.com/mariomarin/dotfiles.git ~/.local/share/chezmoi
   ```

2. Apply NixOS configuration (choose your host):

   ```bash
   cd ~/.local/share/chezmoi/nix/nixos

   # dendrite - ThinkPad T470 laptop
   sudo nixos-rebuild switch --flake .#dendrite

   # mitosis - Virtual machine
   sudo nixos-rebuild switch --flake .#mitosis

   # symbiont - NixOS on WSL
   sudo nixos-rebuild switch --flake .#symbiont
   ```

3. Apply dotfiles (chezmoi and just are now installed via NixOS):

   ```bash
   chezmoi init
   chezmoi apply -v

   # Future NixOS rebuilds can use just
   cd ~/.local/share/chezmoi/nix/nixos
   just switch
   ```

### What Happens Automatically

The `.bootstrap-unix.sh` pre-hook:

- **NixOS**: Verifies Bitwarden CLI is available (no installation, just checks)
- Exits early - all tools installed via `configuration.nix`

## macOS Setup

### Prerequisites (macOS)

None - bootstrap installs everything needed.

### Setup Steps (macOS)

```bash
# Clone dotfiles
git clone https://github.com/mariomarin/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi

# Apply configuration (runs .bootstrap-unix.sh automatically)
chezmoi apply -v
```

### What Happens on Bootstrap (macOS)

The `.bootstrap-unix.sh` pre-hook installs:

1. **Nix** via Determinate Systems installer (flakes enabled by default)
2. **Bitwarden CLI** via `nix profile install` (for secret management)

Then apply nix-darwin configuration:

```bash
cd ~/.local/share/chezmoi/nix/darwin

# First-time setup (installs nix-darwin)
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#malus

# Future rebuilds (just is now installed)
just switch
```

## Other Linux (Non-NixOS)

### Recommended: Install Bitwarden CLI via Package Manager

**Preferred approach** for automatic updates:

```bash
# Debian/Ubuntu (via Snap)
sudo snap install bw

# Fedora/RHEL (via Flatpak)
flatpak install flathub com.bitwarden.desktop

# Arch Linux (via AUR)
yay -S bitwarden-cli
```

### Setup Steps (Other Linux)

```bash
# Install chezmoi first
sh -c "$(curl -fsLS get.chezmoi.io)"

# Clone dotfiles
chezmoi init https://github.com/mariomarin/dotfiles.git

# Apply configuration
chezmoi apply -v
```

### What Happens on Bootstrap (Other Linux)

The `.bootstrap-unix.sh` pre-hook:

1. **Checks** if Bitwarden CLI is already installed (system-wide)
2. **Suggests** package manager installation (preferred)
3. **Fallback**: Downloads latest version to `~/.local/bin` if not found
4. **Warns** about manual updates needed for static binary

To update static binary: Re-run `chezmoi apply` or install via package manager.

## Repository Structure

```text
.install/
└── README.md                  # This file (installation guide)

Root directory:
├── .bootstrap-unix.sh         # Unix/macOS/Linux bootstrap (chezmoi pre-hook)
└── .bootstrap-windows.ps1     # Windows bootstrap (chezmoi pre-hook)
```

## Bootstrap Scripts

Bootstrap scripts run automatically as chezmoi pre-hooks **before** reading source state.

### .bootstrap-unix.sh

- **macOS**: Installs Nix (Determinate Systems) → Bitwarden CLI via Nix profile
- **NixOS**: Verifies Bitwarden CLI exists (fails if missing - add to config)
- **Other Linux**:
  1. Checks if `bw` command exists (system-wide or ~/.local/bin)
  2. Suggests distro-specific package manager installation
  3. Fallback: Downloads latest version to ~/.local/bin (fetches from GitHub API)

### .bootstrap-windows.ps1

- Installs Bitwarden CLI via winget

## Troubleshooting

### Windows: Execution Policy Error

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

### Windows: winget not found

Install "App Installer" from Microsoft Store.

### NixOS: Bootstrap fails "bitwarden-cli not found"

Install it system-wide first:

```bash
nix-env -iA nixos.bitwarden-cli
# Or add to configuration.nix
```

### macOS: Bootstrap fails

Bootstrap requires `curl` (pre-installed on macOS). If Homebrew installation fails, install manually:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Other Linux: Binary not found after bootstrap

Ensure `~/.local/bin` is in your PATH:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Security Note

Always review scripts before running them. Bootstrap scripts are minimal and only install what templates need.

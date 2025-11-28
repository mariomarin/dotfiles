# Installation Scripts

Bootstrap scripts for setting up dotfiles on new machines.

## Bootstrap Philosophy

**Bootstrap scripts install ONLY what chezmoi templates need to render:**

- **Bitwarden CLI** - Required for `{{ bitwarden ... }}` template functions
- **Nix** (macOS only) - Required for nix-darwin system management

**Everything else** is installed declaratively via:

- **NixOS**: `configuration.nix` and `nixos-rebuild`
- **macOS**: nix-darwin configuration
- **Windows**: winget packages in `.chezmoidata/packages.yaml`

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

2. Apply NixOS configuration (sets hostname and installs packages):

   ```bash
   cd ~/.local/share/chezmoi/nix/nixos

   # Choose your host (this sets the hostname)
   # dendrite - ThinkPad T470 laptop
   sudo nixos-rebuild switch --flake .#dendrite

   # mitosis - Virtual machine
   sudo nixos-rebuild switch --flake .#mitosis

   # symbiont - NixOS on WSL
   sudo nixos-rebuild switch --flake .#symbiont
   ```

   **Important**: This sets `networking.hostName` in your NixOS configuration. The hostname change may require a
   reboot or manual update:

   ```bash
   # Verify hostname was updated
   hostname

   # If still wrong, set it manually (or reboot)
   sudo hostnamectl set-hostname dendrite  # or mitosis/symbiont
   ```

3. Apply dotfiles (chezmoi and just are now installed via NixOS):

   **Critical**: Hostname must match your chosen config (dendrite/mitosis/symbiont) for chezmoi to work!

   ```bash
   # Verify hostname matches
   hostname  # Should output: dendrite (or mitosis/symbiont)

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

## Supported Platforms

This configuration **only supports**:

- ✅ **NixOS** (Linux with declarative system management)
- ✅ **macOS** (via nix-darwin)
- ✅ **Windows** (via winget)

### Other Linux Distributions

❌ **Not supported**. If you're on Debian, Ubuntu, Arch, Fedora, etc.:

- **Option 1**: Install NixOS directly (recommended)
- **Option 2**: Use NixOS via WSL on Windows (see symbiont host)
- **Option 3**: Create your own dotfiles configuration for your distro

The bootstrap script will fail on non-NixOS Linux systems.

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
- **Other Linux**: Fails with error message (not supported)

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

### Other Linux: Not supported

This configuration only supports NixOS on Linux. For other distributions:

- Install NixOS directly, or
- Use NixOS via WSL on Windows, or
- Create your own dotfiles configuration

## Security Note

Always review scripts before running them. Bootstrap scripts are minimal and only install what templates need.

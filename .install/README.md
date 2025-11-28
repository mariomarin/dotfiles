# Installation Scripts

Bootstrap scripts for setting up dotfiles on new machines.

## Bootstrap Philosophy

**Separation of concerns:**

1. **Manual Prerequisites** (you install):
   - Package manager (if needed)
   - chezmoi itself

2. **Automatic Bootstrap** (chezmoi pre-hook installs):
   - **Bitwarden CLI** - Required for `{{ bitwarden ... }}` template functions
   - **Nix** (macOS only) - Required for nix-darwin system management

3. **Declarative Packages** (system configuration installs):
   - **NixOS**: `configuration.nix` and `nixos-rebuild`
   - **macOS**: nix-darwin configuration
   - **Windows**: winget packages in `.chezmoidata/packages.yaml`

Bootstrap scripts run automatically as chezmoi pre-hooks when you execute `chezmoi init` or `chezmoi apply`.

## Windows Setup

### Manual Prerequisites (Windows)

```powershell
# Install Git and chezmoi (winget pre-installed on Windows 10/11)
winget install Git.Git
winget install twpayne.chezmoi

# Restart PowerShell to refresh PATH
```

### Automatic Bootstrap + Apply (Windows)

```powershell
# Initialize dotfiles (bootstrap auto-installs Bitwarden CLI via winget)
chezmoi init https://github.com/mariomarin/dotfiles.git

# Login to Bitwarden
bw login
$env:BW_SESSION = bw unlock --raw

# Apply configuration
chezmoi apply -v
```

### What Happens Automatically (Windows)

1. **Bootstrap** (`.bootstrap-windows.ps1` pre-hook):
   - Installs Bitwarden CLI via winget

2. **Declarative Packages** (`run_onchange_` scripts):
   - Installs packages from `.chezmoidata/packages.yaml`
   - Includes: just, nushell, neovim, git, and more

## NixOS Setup

### Manual Prerequisites (NixOS)

```bash
# Install Bitwarden CLI (required for chezmoi templates)
nix-env -iA nixos.bitwarden-cli
# Or add temporarily to configuration.nix: environment.systemPackages = [ pkgs.bitwarden-cli ];

# Get git and chezmoi temporarily
nix-shell -p git chezmoi

# Clone repository
git clone https://github.com/mariomarin/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi/nix/nixos
```

### Apply NixOS Configuration

```bash
# Apply configuration for your host (sets hostname and installs all packages)
sudo nixos-rebuild switch --flake .#dendrite  # or mitosis/symbiont

# Verify hostname matches (critical for chezmoi)
hostname  # Should output: dendrite (or mitosis/symbiont)

# If hostname is wrong, set manually or reboot
sudo hostnamectl set-hostname dendrite  # or mitosis/symbiont
```

### Automatic Bootstrap + Apply (NixOS)

```bash
# Initialize chezmoi (bootstrap verifies Bitwarden CLI exists)
chezmoi init

# Login to Bitwarden
bw login
export BW_SESSION=$(bw unlock --raw)

# Apply dotfiles
chezmoi apply -v
```

**Future updates:** `just nixos` (chezmoi and just now installed via NixOS configuration)

### What Happens Automatically (NixOS)

1. **NixOS Configuration** (`nixos-rebuild switch`):
   - Sets hostname via `networking.hostName`
   - Installs ALL system packages: chezmoi, just, neovim, git, etc.
   - Enables system services

2. **Bootstrap** (`.bootstrap-unix.sh` pre-hook):
   - Verifies Bitwarden CLI is available (no installation)
   - Fails if not found with helpful error message

## macOS Setup

### Manual Prerequisites (macOS)

```bash
# Install chezmoi (choose one method)
brew install chezmoi
# Or without Homebrew:
curl -sfL https://get.chezmoi.io | sh
```

### Automatic Bootstrap + Apply (macOS)

```bash
# Initialize dotfiles (bootstrap auto-installs Nix + Bitwarden CLI)
chezmoi init https://github.com/mariomarin/dotfiles.git

# Login to Bitwarden
bw login
export BW_SESSION=$(bw unlock --raw)

# Apply dotfiles
chezmoi apply -v
```

### Apply nix-darwin Configuration

```bash
cd ~/.local/share/chezmoi/nix/darwin

# First-time setup (installs nix-darwin and all packages)
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#malus
```

**Future updates:** `just darwin` (just now installed via nix-darwin)

### What Happens Automatically (macOS)

1. **Bootstrap** (`.bootstrap-unix.sh` pre-hook):
   - Installs Nix via Determinate Systems installer (flakes enabled)
   - Installs Bitwarden CLI via `nix profile install`

2. **nix-darwin Configuration**:
   - Installs ALL system packages: just, neovim, git, etc.
   - Configures system settings
   - Enables services

## Supported Platforms

This configuration **only supports**:

- ✅ **NixOS** (Linux with declarative system management)
- ✅ **macOS** (via nix-darwin)
- ✅ **Windows** (via winget)

### Other Linux Distributions

❌ **Not supported**. If you're on Debian, Ubuntu, Arch, Fedora, etc.:

- **Option 1**: Install NixOS directly (recommended)
- **Option 2**: Use NixOS via WSL on Windows (see symbiont host)
- **Option 3**: Install Nix via [Determinate Systems installer](https://github.com/DeterminateSystems/nix-installer)
  (untested - may work for package management)
- **Option 4**: Create your own dotfiles configuration for your distro

The bootstrap script will fail on non-NixOS Linux systems. Option 3 may allow you to use Nix package management on your
existing distribution, but this configuration is untested outside of NixOS.

## Repository Structure

```text
.install/
└── README.md                  # This file (installation guide)

Root directory:
├── .bootstrap-unix.sh         # Unix/macOS/Linux bootstrap (chezmoi pre-hook)
└── .bootstrap-windows.ps1     # Windows bootstrap (chezmoi pre-hook)
```

## Bootstrap Scripts

Bootstrap scripts are chezmoi pre-hooks that run automatically **before** reading source state when you execute
`chezmoi init` or `chezmoi apply`. See platform-specific sections above for what each bootstrap script does.

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

Bootstrap requires `curl` (pre-installed on macOS). If Nix installation fails, try installing manually:

```bash
curl -sfL https://install.determinate.systems/nix | sh -s -- install
```

### Other Linux: Not supported

This configuration only supports NixOS on Linux. For other distributions:

- Install NixOS directly, or
- Use NixOS via WSL on Windows, or
- Create your own dotfiles configuration

## Security Note

Always review scripts before running them. Bootstrap scripts are minimal and only install what templates need.

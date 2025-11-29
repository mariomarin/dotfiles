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

**IMPORTANT:**

- **Use PowerShell** (not cmd.exe) for all Windows commands
- winget is required for Windows setup. If you encounter issues with winget not being found,
  see [Windows: winget not found](#windows-winget-not-found) troubleshooting section.

### Manual Prerequisites (Windows)

> **Note:** winget is now auto-installed by the bootstrap script if missing. You can skip Step 1
> if you plan to let the bootstrap handle it.

#### Step 1: Install Git and chezmoi

```powershell
# Install Git and chezmoi using winget (auto-installs during bootstrap if missing)
winget install Git.Git
winget install twpayne.chezmoi

# Restart PowerShell to refresh PATH
```

**Alternative if you prefer manual installation:**

- Git: Download from [git-scm.com](https://git-scm.com/download/win)
- chezmoi: Download from [GitHub releases](https://github.com/twpayne/chezmoi/releases)

> If `winget` is not found and you want to install it before running the bootstrap, see the
> [Windows: winget not found](#windows-winget-not-found) section for manual installation options.

### Automatic Bootstrap + Apply (Windows)

```powershell
# Initialize dotfiles (bootstrap auto-installs winget, Nushell, and Bitwarden CLI)
chezmoi init https://github.com/mariomarin/dotfiles.git

# ⚠️  IMPORTANT: Restart PowerShell after first init to load bw command
# Close and reopen PowerShell, then continue:

# Login to Bitwarden
bw login

# Unlock and set session (PowerShell syntax)
$env:BW_SESSION = bw unlock --raw

# Apply configuration
chezmoi apply -v
```

**If using cmd.exe instead of PowerShell:**

```cmd
REM Login to Bitwarden
bw login

REM Unlock vault (copy the output token)
bw unlock --raw

REM Set session (paste the token from above)
set BW_SESSION=your-session-token-here

REM Apply configuration
chezmoi apply -v
```

### What Happens Automatically (Windows)

1. **Bootstrap** (`bootstrap-windows.ps1` pre-hook):
   - Installs/registers winget via [winget-install script](https://github.com/asheroto/winget-install) (if not found)
   - Installs winget dependencies (VCLibs, UI.Xaml)
   - Configures PATH with literal `%LOCALAPPDATA%`
   - Installs Nushell via winget
   - Installs Bitwarden CLI via winget

2. **Declarative Packages** (`run_onchange_windows-install-packages.nu` script):
   - Installs packages from `.chezmoidata/packages.yaml`
   - Includes: just, neovim, git, and more

## NixOS Setup

### Manual Prerequisites (NixOS)

#### Option 1: Use bootstrap shell (Recommended for first-time setup)

```bash
# Clone repository
nix-shell -p git --run "git clone https://github.com/mariomarin/dotfiles.git ~/.local/share/chezmoi"

# Enter bootstrap environment (provides nushell, bitwarden-cli, git, chezmoi)
cd ~/.local/share/chezmoi
nix-shell .install/shell.nix
```

#### Option 2: Install system-wide (Recommended for permanent setup)

Add to `/etc/nixos/configuration.nix`:

```nix
environment.systemPackages = with pkgs; [
  nushell
  bitwarden-cli
  git
  chezmoi
];
```

Then apply:

```bash
# Rebuild NixOS configuration
sudo nixos-rebuild switch

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

2. **Bootstrap** (`bootstrap-unix.sh` pre-hook):
   - Verifies Nushell and Bitwarden CLI are available
   - If missing, suggests using `.install/shell.nix` or adding to system packages
   - No automatic installation (packages managed by NixOS configuration)

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

1. **Bootstrap** (`bootstrap-unix.sh` pre-hook):
   - Installs Nix via Determinate Systems installer (flakes enabled)
   - Installs Nushell via `nix profile install`
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
├── README.md                  # This file (installation guide)
├── bootstrap-unix.sh          # Unix/macOS/NixOS bootstrap (chezmoi pre-hook)
└── bootstrap-windows.ps1      # Windows bootstrap (chezmoi pre-hook)
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

> **Note:** The bootstrap script now automatically installs winget using the
> [asheroto/winget-install](https://github.com/asheroto/winget-install) script. This handles all edge cases
> including dependencies, PATH setup, and different Windows versions.

#### What the bootstrap does automatically

The bootstrap script uses the [asheroto/winget-install](https://github.com/asheroto/winget-install) script:

- Detects if winget is already installed (checks multiple locations)
- Installs required dependencies (VCLibs, UI.Xaml)
- Registers App Installer package
- Handles different Windows versions (10/11, Server 2019, Server Core)
- Uses literal `%LOCALAPPDATA%` in PATH (prevents issues with profile changes)
- Works without Microsoft Store access
- Refreshes PATH in current session

If installation fails, the bootstrap provides manual installation options.

#### Manual installation (if bootstrap fails)

If the automatic setup fails, you can install winget manually:

##### Option 1: Run winget-install directly (Recommended)

```powershell
irm https://get.winget.run | iex
```

##### Option 2: Install from Microsoft Store

1. Open Microsoft Store app
2. Search for "App Installer"
3. Click Install
4. Restart PowerShell

##### Option 3: Download manually

Download the latest `.msixbundle` from:

- Official Microsoft: <https://aka.ms/getwinget>
- GitHub releases: <https://github.com/microsoft/winget-cli/releases>

##### Option 4: Install Git and chezmoi without winget

- Git: <https://git-scm.com/download/win>
- chezmoi: <https://github.com/twpayne/chezmoi/releases>

Then run `chezmoi init` - the bootstrap will install winget for package management.

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

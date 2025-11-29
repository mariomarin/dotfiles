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

Since winget may not be available on a fresh Windows install, use these prerequisite-free installers:

#### Step 1: Install Git

**Option 1:** Download installer from [git-scm.com](https://git-scm.com/download/win)

**Option 2:** If winget is available: `winget install Git.Git`

#### Step 2: Install chezmoi

```powershell
# PowerShell one-liner (no prerequisites needed)
iex "&{$(irm 'https://get.chezmoi.io/ps1')}"
```

**Alternative:** Download from [chezmoi releases](https://github.com/twpayne/chezmoi/releases)

#### Step 3: Restart PowerShell

```powershell
# Close and reopen PowerShell to refresh PATH
```

> **Note:** The bootstrap script will auto-install winget, Nushell, and Bitwarden CLI on first run.

### Setup (Windows)

Before initializing chezmoi, create a minimal configuration file:

```powershell
# 1. Create config directory
mkdir -Force ~/.config/chezmoi

# 2. Create minimal config file
@"
[bitwarden]
command = "bw"

[data]
hostname = "prion"
"@ | Set-Content ~/.config/chezmoi/chezmoi.toml
```

> **Note:** Replace `"prion"` with your machine's hostname. Available machines are defined in `.chezmoidata/machines.yaml`

```powershell
# 3. Initialize dotfiles
chezmoi init https://github.com/mariomarin/dotfiles.git
```

**Continue with setup:**

```powershell
# ⚠️  IMPORTANT: If Nushell was just installed, restart PowerShell before continuing
#              (the bootstrap will warn you if this is required)

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

### Setup (NixOS)

Before initializing chezmoi, create a minimal configuration file:

```bash
# 1. Create config directory
mkdir -p ~/.config/chezmoi

# 2. Create minimal config file
cat > ~/.config/chezmoi/chezmoi.toml << 'EOF'
[bitwarden]
command = "bw"

[data]
hostname = "dendrite"
EOF
```

> **Note:** Replace `"dendrite"` with your machine's hostname. Available machines are defined in `.chezmoidata/machines.yaml`

### Apply Configuration (NixOS)

```bash
# From within the nix-shell environment

# Initialize chezmoi
chezmoi init

# Login to Bitwarden
bw login
export BW_SESSION=$(bw unlock --raw)

# Apply dotfiles
chezmoi apply -v

# Apply NixOS configuration (sets hostname and installs chezmoi, just, and all packages permanently)
sudo nixos-rebuild switch --flake ~/.local/share/chezmoi/nix/nixos#dendrite  # or mitosis/symbiont

# Verify hostname was set correctly
hostname  # Should output: dendrite (or mitosis/symbiont)
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
# Install Nix (if not already installed)
curl -sfL https://install.determinate.systems/nix | sh -s -- install

# Clone dotfiles
git clone https://github.com/mariomarin/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi

# Enter bootstrap shell (provides nushell, bitwarden-cli, git, chezmoi)
nix-shell .install/shell.nix
```

### Setup (macOS)

Before initializing chezmoi, create a minimal configuration file:

```bash
# 1. Create config directory
mkdir -p ~/.config/chezmoi

# 2. Create minimal config file
cat > ~/.config/chezmoi/chezmoi.toml << 'EOF'
[bitwarden]
command = "bw"

[data]
hostname = "malus"
EOF
```

> **Note:** Replace `"malus"` with your machine's hostname. Available machines are defined in `.chezmoidata/machines.yaml`

### Apply Configuration (macOS)

```bash
# From within the nix-shell environment

# Initialize chezmoi
chezmoi init

# Login to Bitwarden
bw login
export BW_SESSION=$(bw unlock --raw)

# Apply dotfiles
chezmoi apply -v

# Apply nix-darwin configuration (installs chezmoi, just, and all packages permanently)
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#malus
```

**Future updates:** `just darwin` (just now installed via nix-darwin)

### What Happens (macOS)

1. **Bootstrap Shell** (`.install/shell.nix`):
   - Provides temporary environment with: nushell, bitwarden-cli, git, chezmoi
   - No permanent installations to user profile

2. **nix-darwin Configuration**:
   - Installs ALL system packages permanently: just, neovim, git, etc.
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

# Installation Scripts

Bootstrap scripts for setting up dotfiles on new machines.

## Bootstrap Philosophy

**Separation of concerns:**

1. **Manual Prerequisites** (you install):
   - **Nix** (macOS/Linux) - Package manager for development tools
   - **Git** (Windows only) - For cloning repository

2. **Bootstrap Environment** (nix-shell provides on Unix):
   - chezmoi, just, yq, Bitwarden CLI, Nushell, devenv, git
   - All dependencies in one isolated environment via `.install/shell.nix`

3. **Windows Bootstrap** (script installs via winget):
   - chezmoi, just, yq, Bitwarden CLI, Nushell
   - Auto-installs winget if not present

4. **System Packages** (managed by system configuration):
   - **NixOS**: `configuration.nix` and `nixos-rebuild`
   - **macOS**: nix-darwin configuration
   - **Windows**: winget packages in `.chezmoidata/packages.yaml`

**Key concept**: Unix uses nix-shell for reproducible bootstrap environment. Windows uses winget for
declarative package installation.

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
cd nix/nixos
sudo nixos-rebuild switch --flake .#dendrite  # or .#mitosis, .#symbiont

# Verify hostname was set correctly
hostname  # Should output: dendrite (or mitosis/symbiont)
```

**Future updates:** `just nixos` (chezmoi and just now installed via NixOS configuration)

### What Happens Automatically (NixOS)

1. **Bootstrap** (`bootstrap-unix.sh`):
   - Verifies NixOS
   - Clones repository
   - Enters nix-shell with chezmoi, just, yq, Bitwarden CLI
   - Prompts for Bitwarden login and unlocks vault
   - Prompts for hostname selection
   - Initializes chezmoi
   - **Automatically runs `just nixos/first-time`** to apply system configuration

2. **NixOS Configuration** (`just nixos/first-time` → `nixos-rebuild switch`):
   - Sets hostname via `networking.hostName`
   - Installs ALL system packages: neovim, git, development tools, etc.
   - Enables system services
   - Configures boot loader, networking, users

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

### What Happens Automatically (macOS)

With the automated bootstrap, you don't need to run these commands manually:

1. **Bootstrap** (`bootstrap-unix.sh`):
   - Installs Nix (if not present)
   - Clones repository
   - Enters nix-shell with chezmoi, just, yq, Bitwarden CLI
   - Prompts for Bitwarden login and unlocks vault
   - Prompts for hostname selection
   - Initializes chezmoi
   - **Automatically runs `just darwin/first-time`** to apply nix-darwin configuration

2. **nix-darwin Configuration** (`just darwin/first-time`):
   - Installs ALL system packages permanently: just, neovim, git, etc.
   - Configures Homebrew casks for GUI apps (only when not in nixpkgs)
   - Sets macOS system defaults
   - Installs fonts

**Future updates:** `just darwin` (just now installed via nix-darwin)

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

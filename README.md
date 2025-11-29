# Dotfiles

Personal configuration files managed with chezmoi, using Nix for packages and Bitwarden for secrets.

> ⚠️ **Warning:** Review the code before applying. These are personal configurations—fork and customize for your own
> use.

## Features

- **Cross-platform**: NixOS, macOS (nix-darwin), Windows, and WSL
- **Declarative packages**: Managed via Nix on Unix systems, winget on Windows
- **Secrets management**: SSH keys and tokens securely stored in Bitwarden
- **Templating**: Dynamic configuration based on OS, architecture, and custom data
- **Auto-sync**: Changes automatically committed and pushed to git
- **Modular configuration**: Organized structure under `private_dot_config/` and nix modules
- **LazyVim**: Pre-configured Neovim with language support and AI integration

## Quick Start

> 📖 **For detailed installation instructions and bootstrap philosophy**, see [.install/README.md](.install/README.md)

### Installation Pattern

All platforms follow the same pattern:

1. **Manual Prerequisites** - Install chezmoi (platform-specific)
2. **Automatic Bootstrap** - Run `chezmoi init`, bootstrap installs dependencies automatically
3. **Apply Configuration** - Login to Bitwarden and apply dotfiles

<details>
<summary>NixOS</summary>

**Manual Prerequisites:**

```bash
# Use bootstrap shell (provides nushell, bitwarden-cli, git, chezmoi)
nix-shell -p git --run "git clone https://github.com/mariomarin/dotfiles.git ~/.local/share/chezmoi"
cd ~/.local/share/chezmoi
nix-shell .install/shell.nix
```

**Setup:**

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

> **Note:** Replace `"dendrite"` with your machine's hostname. Available machines are defined in [.chezmoidata/machines.yaml](.chezmoidata/machines.yaml)

**Apply Configuration:**

```bash
# From within the nix-shell environment

# Initialize chezmoi
chezmoi init

# Login to Bitwarden and apply
bw login
export BW_SESSION=$(bw unlock --raw)
chezmoi apply -v

# Apply NixOS configuration (sets hostname and installs chezmoi, just, and all packages permanently)
sudo nixos-rebuild switch --flake ~/.local/share/chezmoi/nix/nixos#dendrite  # or mitosis/symbiont

# Verify hostname was set correctly
hostname  # Should output: dendrite (or mitosis/symbiont)
```

**Future updates:** `just nixos`

See [nix/nixos/README.md](nix/nixos/README.md) for detailed setup and configuration.

</details>

<details>
<summary>macOS (nix-darwin)</summary>

**Manual Prerequisites:**

```bash
# Install Nix (if not already installed)
curl -sfL https://install.determinate.systems/nix | sh -s -- install

# Clone dotfiles
git clone https://github.com/mariomarin/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi

# Enter bootstrap shell (provides nushell, bitwarden-cli, git, chezmoi)
nix-shell .install/shell.nix
```

**Setup:**

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

> **Note:** Replace `"malus"` with your machine's hostname. Available machines are defined in [.chezmoidata/machines.yaml](.chezmoidata/machines.yaml)

**Apply Configuration:**

```bash
# From within the nix-shell environment

# Initialize chezmoi
chezmoi init

# Login to Bitwarden and apply
bw login
export BW_SESSION=$(bw unlock --raw)
chezmoi apply

# Apply nix-darwin configuration (installs chezmoi, just, and all packages permanently)
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#malus
```

**Future updates:** `just darwin`

See [nix/darwin/README.md](nix/darwin/README.md) for detailed setup and configuration.

</details>

<details>
<summary>Windows</summary>

**Prerequisites:**

```powershell
# 1. Install Git (if not already installed)
# Download and run installer from: https://git-scm.com/download/win
# Or use winget if available: winget install Git.Git

# 2. Install chezmoi via PowerShell one-liner
iex "&{$(irm 'https://get.chezmoi.io/ps1')}"

# 3. Restart PowerShell to refresh PATH
```

**Setup:**

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

**Continue setup:**

```powershell
# If Nushell was just installed, restart PowerShell
# (The bootstrap will warn you if this is required)

# Login to Bitwarden and apply
bw login
$env:BW_SESSION = bw unlock --raw
chezmoi apply
```

**What happens automatically:**

- Interactive hostname selection (first run only)
- winget registration and PATH setup (if not found)
- Nushell and Bitwarden CLI installation
- Declarative package installation (just, neovim, direnv, etc.)

> **Note:** Hostname is selected once during first init and saved to `~/.config/chezmoi/chezmoi.toml`.
> The bootstrap will auto-install winget, Nushell, and Bitwarden CLI on first run.

</details>

<details>
<summary>WSL (NixOS on Windows)</summary>

For a full NixOS experience on Windows via WSL2:

```powershell
# After setting up Windows dotfiles above
cd $env:USERPROFILE\.local\share\chezmoi\wsl
just setup
```

See [wsl/README.md](wsl/README.md) for detailed WSL setup.

</details>

## Repository Structure

```text
.
├── nix/                          # Nix configurations
│   ├── nixos/                    # NixOS system configuration
│   ├── darwin/                   # macOS (nix-darwin) configuration
│   └── common/                   # Shared Nix modules
├── private_dot_config/           # Application configs → ~/.config/
│   ├── nvim/                     # Neovim (LazyVim)
│   ├── tmux/                     # Tmux configuration
│   ├── zsh/                      # Zsh shell configuration
│   ├── zim/                      # Zim framework for Zsh
│   ├── leftwm/                   # LeftWM window manager
│   └── kmonad/                   # Keyboard remapping
├── private_dot_local/            # Local data → ~/.local/
│   ├── bin/                      # User binaries
│   └── share/                    # Shared data
├── docs/                         # Documentation
├── wsl/                          # WSL-specific setup
└── .chezmoiscripts/              # Scripts run during apply
```

For chezmoi naming conventions, see the
[official documentation](https://www.chezmoi.io/reference/source-state-attributes/).

## Documentation

| Topic | Location |
| ----- | -------- |
| NixOS setup | [nix/nixos/README.md](nix/nixos/README.md) |
| macOS setup | [nix/darwin/README.md](nix/darwin/README.md) |
| WSL setup | [wsl/README.md](wsl/README.md) |
| Secrets management | [docs/secrets.md](docs/secrets.md) |
| Neovim keybindings | [private_dot_config/nvim/KEYBINDINGS.md](private_dot_config/nvim/KEYBINDINGS.md) |
| Tmux keybindings | [private_dot_config/tmux/KEYBINDINGS.md](private_dot_config/tmux/KEYBINDINGS.md) |
| LeftWM keybindings | [private_dot_config/leftwm/KEYBINDINGS.md](private_dot_config/leftwm/KEYBINDINGS.md) |
| KMonad keybindings | [private_dot_config/kmonad/KEYBINDINGS.md](private_dot_config/kmonad/KEYBINDINGS.md) |

## Common Commands

```bash
# List all available tasks
just --list

# Apply dotfiles (default, runs quick-apply)
just

# Apply with verbose output
just apply

# Preview changes before applying
just diff

# Update everything (system packages, plugins, etc.)
just update

# System operations
just nixos          # NixOS rebuild (nix/nixos/switch)

# Component operations
just nvim           # Sync Neovim plugins
just tmux           # Reload tmux config
just zim            # Update Zim modules

# Development
just format         # Format all files
just lint           # Run linting checks
```

## Customization

Fork this repository and make it yours. Key files to modify:

- `nix/nixos/configuration.nix` or `nix/darwin/configuration.nix` - System configuration
- `.chezmoidata/packages.yaml` - Declarative package lists (Windows only; Nix elsewhere)
- `private_dot_config/nvim/` - Neovim configuration
- `private_dot_config/tmux/` - Tmux configuration
- `private_dot_config/zsh/` - Zsh configuration

Remove personal identifiers:

- Git configuration files
- SSH keys in Bitwarden templates
- Machine-specific settings

## Credits

Built with:

- [chezmoi](https://www.chezmoi.io/) - Dotfile management
- [Nix](https://nixos.org/) - Package management and system configuration
- [LazyVim](https://www.lazyvim.org/) - Neovim configuration framework
- [Bitwarden](https://bitwarden.com/) - Secrets management

## License

MIT License - See [LICENSE](LICENSE) for details.

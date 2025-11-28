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
# Get git and chezmoi temporarily
nix-shell -p git chezmoi

# Clone repository
git clone https://github.com/mariomarin/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
```

**Apply Configuration:**

```bash
# This runs nixos-rebuild which installs chezmoi, just, and all system packages
sudo nixos-rebuild switch --flake .#dendrite  # or mitosis/symbiont

# Verify hostname matches (critical for chezmoi)
hostname

# Initialize chezmoi (bootstrap verifies Bitwarden CLI)
chezmoi init

# Login to Bitwarden and apply
bw login
export BW_SESSION=$(bw unlock --raw)
chezmoi apply -v
```

**Future updates:** `just nixos`

See [nix/nixos/README.md](nix/nixos/README.md) for detailed setup and configuration.

</details>

<details>
<summary>macOS (nix-darwin)</summary>

**Manual Prerequisites:**

```bash
# Install chezmoi (choose one)
brew install chezmoi
# Or without Homebrew:
curl -sfL https://get.chezmoi.io | sh
```

**Automatic Bootstrap + Apply:**

```bash
# Initialize dotfiles (bootstrap auto-installs Nix + Bitwarden CLI)
chezmoi init https://github.com/mariomarin/dotfiles.git

# Login to Bitwarden and apply
bw login
export BW_SESSION=$(bw unlock --raw)
chezmoi apply

# Apply nix-darwin configuration
cd ~/.local/share/chezmoi
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#malus
```

**Future updates:** `just darwin`

See [nix/darwin/README.md](nix/darwin/README.md) for detailed setup and configuration.

</details>

<details>
<summary>Windows</summary>

**Manual Prerequisites:**

```powershell
# Install Git and chezmoi (winget pre-installed on Windows 10/11)
winget install Git.Git
winget install twpayne.chezmoi

# Restart PowerShell to refresh PATH
```

**Automatic Bootstrap + Apply:**

```powershell
# Initialize dotfiles (bootstrap auto-installs Bitwarden CLI)
chezmoi init https://github.com/mariomarin/dotfiles.git

# Login to Bitwarden and apply
bw login
$env:BW_SESSION = bw unlock --raw
chezmoi apply
```

**What happens automatically:** Packages (just, nushell, neovim, etc.) install via declarative package management.

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

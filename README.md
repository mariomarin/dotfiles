# Dotfiles

Personal configuration files managed with chezmoi, using Nix for packages and Bitwarden for secrets.

> ⚠️ **Warning:** Review the code before applying. These are personal configurations—fork and customize for your own
> use.

## Features

- **Cross-platform**: NixOS, macOS (nix-darwin), Windows, and WSL
- **Declarative packages**: NixOS system config, nix-darwin for macOS, winget for Windows
- **Nix-based bootstrap**: Automated dependency installation via nix-shell on first run
- **Secrets management**: SSH keys and tokens securely stored in Bitwarden
- **Templating**: Dynamic configuration based on OS, architecture, and custom data
- **Development environments**: Per-project tooling via devenv.nix
- **Modular configuration**: Organized structure under `private_dot_config/` and nix modules
- **LazyVim**: Pre-configured Neovim with language support and AI integration

## Quick Start

### Prerequisites

**macOS/Linux:**

- Nix package manager (install if not present):

  ```bash
  curl -sfL https://install.determinate.systems/nix | sh -s -- install
  ```

**Windows:**

- PowerShell (pre-installed on Windows)

### Installation

#### Step 1: Clone repository

```bash
git clone https://github.com/mariomarin/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
```

#### Step 2: Platform-specific setup

**Unix (macOS/Linux):**

```bash
# Enter nix-shell (provides all dependencies: chezmoi, just, yq, bw, etc.)
nix-shell .install/shell.nix

# Set hostname (required - choose from: dendrite, malus, prion, symbiont, mitosis, spore)
export HOSTNAME=dendrite  # Replace with your machine name

# Initialize dotfiles
chezmoi init --apply

# Unlock Bitwarden for secrets
bw login
just bw-unlock  # Saves session to .env.local
just apply      # Apply all configurations with secrets
```

**Windows:**

```powershell
# Install dependencies (chezmoi, just, yq, bw, nushell)
.install/bootstrap-windows.ps1

# Set hostname (required - choose from: dendrite, malus, prion, symbiont, mitosis, spore)
$env:HOSTNAME = "prion"  # Replace with your machine name

# Initialize dotfiles
chezmoi init --apply

# Unlock Bitwarden for secrets
bw login
just bw-unlock  # Saves session to .env.local
just apply      # Apply all configurations with secrets
```

**NixOS/Darwin System Configuration:**

```bash
# NixOS: Apply system configuration
cd nix/nixos && just switch  # Auto-detects hostname

# macOS: Apply nix-darwin configuration
just darwin-first-time  # Auto-detects hostname via scutil
```

### Platform-Specific Details

<details>
<summary>💡 NixOS</summary>

**System manages:** All packages, services, boot, networking
**Update:** `just nixos`
**Docs:** [nix/nixos/README.md](nix/nixos/README.md)

</details>

<details>
<summary>💡 macOS (nix-darwin)</summary>

**System manages:** CLI tools, GUI apps (nixpkgs), Homebrew casks (apps not in nixpkgs)
**Update:** `just darwin`
**Docs:** [nix/darwin/README.md](nix/darwin/README.md)

</details>

<details>
<summary>💡 Windows</summary>

**Packages:** Managed via winget (`.chezmoidata/packages.yaml`)
**Development:** Use WSL with NixOS for devenv
**WSL Setup:** [wsl/README.md](wsl/README.md)

</details>

> 📖 **Detailed installation guide:** [.install/README.md](.install/README.md)

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

**Package Management:**

- **NixOS**: `nix/nixos/modules/*.nix` - All packages via NixOS modules
- **macOS**: `nix/darwin/modules/*.nix` - All packages via nix-darwin
- **Windows**: `.chezmoidata/packages.yaml` - Declarative winget packages only

**Configuration Files:**

- `private_dot_config/nvim/` - Neovim configuration
- `private_dot_config/tmux/` - Tmux configuration
- `private_dot_config/zsh/` - Zsh configuration

**Remove personal identifiers:**

- Git configuration files
- SSH keys in Bitwarden templates
- Machine-specific settings in `.chezmoidata/machines.yaml`

## Credits

Built with:

- [chezmoi](https://www.chezmoi.io/) - Dotfile management
- [Nix](https://nixos.org/) - Package management and system configuration
- [LazyVim](https://www.lazyvim.org/) - Neovim configuration framework
- [Bitwarden](https://bitwarden.com/) - Secrets management

## License

MIT License - See [LICENSE](LICENSE) for details.

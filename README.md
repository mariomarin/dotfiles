# Dotfiles

Personal configuration files managed with chezmoi, using Nix for packages and Bitwarden for secrets.

> ⚠️ **Warning:** Review the code before applying. These are personal configurations—fork and customize for your own
> use.

## Features

- **Cross-platform**: NixOS, macOS (nix-darwin), Windows, WSL
- **Declarative packages**: NixOS/nix-darwin system configs, winget for Windows
- **Secrets management**: Bitwarden integration for SSH keys and tokens
- **Shell frameworks**: Zim for Zsh (Unix), Oh My Posh for PowerShell (Windows)
- **Development environments**: Per-project devenv.nix, LazyVim Neovim setup

## Quick Start

### One-Line Installation

**macOS/NixOS:**

```bash
curl -sfL https://raw.githubusercontent.com/mariomarin/dotfiles/main/.install/bootstrap-unix.sh | sh
```

**Windows:**

```powershell
iwr -useb https://raw.githubusercontent.com/mariomarin/dotfiles/main/.install/bootstrap-windows.ps1 | iex
```

The bootstrap script will:

- Install Nix package manager (macOS only, if not present)
- Clone the repository
- Enter nix-shell environment (Unix) or install tools via winget (Windows)
- Setup Bitwarden and unlock vault
- Prompt for hostname selection
- Initialize chezmoi

### After Installation

```bash
cd ~/.local/share/chezmoi
just apply      # Apply all configurations
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

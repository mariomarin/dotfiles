# Dotfiles

This is a chezmoi-managed dotfiles repository that uses templating and external data sources to manage system configurations across different machines.

## Quick Start

### Install chezmoi and initialize dotfiles
```bash
make install
```

### Initialize with this repository
```bash
make init
```

## Directory Structure

This repository uses [chezmoi's naming conventions](https://www.chezmoi.io/reference/source-state-attributes/), which makes directories look unusual at first glance:

```
.
├── private_dot_config/           # → ~/.config/
│   ├── alacritty/               # → ~/.config/alacritty/
│   ├── nvim/                    # → ~/.config/nvim/
│   └── zsh/                     # → ~/.config/zsh/
├── private_dot_local/           # → ~/.local/
│   ├── bin/                     # → ~/.local/bin/
│   └── share/                   # → ~/.local/share/
│       └── tmux/plugins/        # → ~/.local/share/tmux/plugins/
├── dot_zshenv                   # → ~/.zshenv
├── dot_tmux.conf                # → ~/.tmux.conf
└── executable_dot_xinitrc       # → ~/.xinitrc (with executable permissions)
```

### Chezmoi Naming Conventions

- `private_` prefix = directory with 700 permissions
- `dot_` prefix = hidden file/directory (becomes `.` in the target)
- `executable_` prefix = file with executable permissions
- `.chezmoiexternal.toml` = external dependencies fetched automatically

This naming scheme allows chezmoi to recreate the exact file structure and permissions in your home directory.

## Makefile Targets

```bash
# Initialize chezmoi with this repository and apply
make init

# Pull latest changes and show diff
make diff

# Apply changes verbosely
make apply

# Install chezmoi (if not already installed)
make install

# Sync (currently empty - reserved for future use)
make sync
```

## Common Chezmoi Commands

```bash
# Apply changes to the system
chezmoi apply -v

# Preview changes before applying
chezmoi diff

# Edit a file and immediately apply changes
chezmoi edit --apply ~/.zshrc

# Add a new file to chezmoi
chezmoi add ~/.config/newapp/config.toml
```

## Key Features

- Declarative external dependency management via `.chezmoiexternal.toml` files
- Dynamic version management for external tools (latest by default, with pinning support)
- Auto-commit and auto-push enabled for seamless updates
- Custom Zsh completion system via zimfw modules
- NixOS-specific syncthing systemd service management
- Modular configuration structure under `private_dot_config/` and `private_dot_local/`

## Chezmoi Configuration

The repository is configured via `chezmoi.toml.tmpl`:

- **Source Directory**: `~/.local/share/chezmoi`
- **Merge Tool**: `nvim -d` (for handling conflicts)
- **Git Integration**:
  - Auto-commit: Enabled (changes are automatically committed)
  - Auto-push: Enabled (commits are automatically pushed)
  
This means any changes made via `chezmoi apply` are automatically version controlled.

## External Dependencies

This repository automatically manages the following external tools and resources:

### Development Tools
- **container-use** (`~/.local/bin/container-use`) - Docker-based development environments
  - Alias: `cu` (symlinked)
  - Custom Zsh completions included

### Shell Framework
- **zimfw** (`~/.config/zim/zimfw.zsh`) - Modular Zsh framework
  - Auto-updates to latest release
  - Custom modules for tool completions

### Terminal
- **Alacritty themes** (`~/.config/alacritty/themes/`) - Color schemes for Alacritty terminal

### Tmux Plugins (via TPM)
- **tpm** - Tmux Plugin Manager
- **tmux-sensible** - Basic tmux settings everyone can agree on
- **minimal-tmux-status** - Clean, minimal tmux theme
- **tmux-resurrect** - Persists tmux environment across system restarts
- **tmux-continuum** - Automatic tmux session save/restore
- **tmux-fingers** - Copy/paste with vimium-like hints in tmux
- **tmux-tilish** - I3wm-like keybindings for tmux
- **tmux-navigate** - Seamless navigation between tmux panes and vim splits
- **tmux-fzf** - Use fzf to manage tmux work environment
- **tmux-fuzzback** - Search tmux scrollback buffer using fzf
- **extrakto** - Quickly select, copy/insert text

### Utilities
- **pulseaudio-control** (`~/.local/bin/pulseaudio-control`) - Polybar PulseAudio control script

## Version Management

External tools support dynamic version management through `.chezmoidata.toml`:

```toml
# By default, tools use latest GitHub releases
# To pin specific versions, uncomment and modify:

[versions]
containerUse = "v0.4.2"  # Container-based development environments
zimfw = "v1.18.0"       # Zim framework for Zsh
```

## Zsh Completions

Custom completions are managed via zimfw modules:

1. Located in `private_dot_config/zim/modules/<tool-name>/`
2. Auto-generate completion files when the tool binary changes
3. Load before the main completion module for proper initialization

Example: The `container-use` module provides completions for both `container-use` and `cu` commands.

## Chezmoi Scripts

Scripts in `.chezmoiscripts/` run automatically during `chezmoi apply`:

- **`run_onchange_syncthing-user-unit.sh.tmpl`**: NixOS-specific script that manages the syncthing systemd user service
  - Creates direct symlinks to the Nix store path
  - Automatically fixes broken symlinks when syncthing updates
  - Only runs when the script content changes

## Template System

Chezmoi uses Go's text/template system. Files ending in `.tmpl` are processed as templates:

### Available Variables
- `{{ .chezmoi.os }}` - Operating system (linux, darwin, windows)
- `{{ .chezmoi.arch }}` - Architecture (amd64, arm64)
- `{{ .chezmoi.homeDir }}` - User's home directory
- `{{ .chezmoi.username }}` - Current username
- Custom data from `.chezmoidata.toml`

### Template Functions
- `{{ gitHubLatestRelease "owner/repo" }}` - Get latest release info from GitHub
- `{{ hasKey . "key" }}` - Check if a key exists in data
- `{{ joinPath "path" "segments" }}` - Join path segments

### Example: Dynamic Versions
```toml
# .chezmoiexternal.toml.tmpl
{{- $version := gitHubLatestRelease "owner/repo" -}}
url = "https://github.com/owner/repo/releases/download/{{ $version.TagName }}/..."
```

## Shell Configuration (Zsh)

The repository includes a comprehensive Zsh configuration:

### File Structure
- `dot_zshenv` - Environment variables (sourced first)
- `private_dot_config/zsh/dot_zshrc` - Interactive shell configuration
- `private_dot_config/zim/` - Zim framework configuration and modules

### Key Components
- **Zim Framework**: Modular Zsh configuration framework
  - Manages plugins via `zimrc`
  - Custom modules in `modules/` directory
  - Auto-updates to latest version

### Notable Aliases
- `vi` → `nvim`
- `ce` → `chezmoi edit --apply`
- `k` → `kubectl`
- Git workflow aliases (pr, checks, merge, approve)

### Integrations
- Zoxide (modern `cd` replacement)
- Direnv (environment variable management)
- Atuin (shell history sync)
- Kubernetes completions
- AWS SSO completions

## Neovim Configuration (LazyVim)

The Neovim setup uses LazyVim, a modern Neovim configuration framework:

### Structure
- `private_dot_config/nvim/init.lua` - Entry point
- `private_dot_config/nvim/lua/` - Lua configuration modules
  - `config/` - Core configuration (options, keymaps, lazy.nvim)
  - `plugins/` - Custom plugin configurations
- `.neoconf.json` - Neovim LSP configuration
- `stylua.toml` - Lua code formatting rules

### Key Features
- **Base**: LazyVim distribution with sensible defaults
- **Language Support**: Pre-configured extras for Go, TypeScript, Python, Rust, YAML, Docker, Markdown
- **AI Integration**: Claude Code integration
  - Toggle Claude Code with `<leader>cc`
  - Continue conversations with `<leader>c.`
  - Auto-reload files modified by Claude
- **File Explorer**: nvim-tree (accessible with `<leader>e`)
- **Colorscheme**: Catppuccin (mocha flavor)
- **Navigation**: Leap.nvim for quick cursor movement
- **Tmux Integration**: Seamless pane navigation
- **Session Management**: vim-obsession for persistent sessions
- **Chezmoi Integration**: Auto-apply on save for chezmoi-managed files

### Default LazyVim Keymaps
- `<leader><space>` - Find files
- `<leader>ff` - Find files
- `<leader>sg` - Search grep
- `<leader>bb` - Switch buffers
- `<leader>ca` - Code actions
- `<leader>cf` - Format code
- And many more (press `<leader>sk` to see all keymaps)

### NixOS Compatibility
Special configurations are included for NixOS users:
- Mason package manager is configured to use system-installed tools first
- Python debugging automatically detects and uses system debugpy
- LSP servers should be installed via Nix rather than Mason
- Disabled plugins that may conflict with NixOS restrictions

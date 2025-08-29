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

## Common Commands

```bash
# Apply changes to the system
chezmoi apply -v

# Preview changes before applying
chezmoi diff

# Full sync
make sync
```

## Key Features

- Declarative external dependency management via `.chezmoiexternal.toml` files
- Dynamic version management for external tools (latest by default, with pinning support)
- Auto-commit and auto-push enabled for seamless updates
- Custom Zsh completion system via zimfw modules
- NixOS-specific syncthing systemd service management
- Modular configuration structure under `private_dot_config/` and `private_dot_local/`

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
- **tmux-thumbs** - Like vimium/vimperator for tmux
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

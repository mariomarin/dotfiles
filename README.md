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
- Auto-commit and auto-push enabled for seamless updates
- NixOS-specific syncthing systemd service management
- Modular configuration structure under `private_dot_config/` and `private_dot_local/`

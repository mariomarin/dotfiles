# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a chezmoi-managed dotfiles repository that uses templating and external data sources to manage system configurations across different machines.

## Common Commands

### Chezmoi Operations
```bash
# Apply changes to the system
chezmoi apply -v

# See what changes will be made
chezmoi diff

# Initialize chezmoi with this repository
make init

# Pull latest changes and show diff
make diff

# Full sync (includes updating tmux plugins, doom emacs, zimfw)
make sync
```

### Tool-Specific Sync Commands
```bash
# Update tmux plugin manager plugins
make sync-tpm

# Sync Doom Emacs packages
make sync-doom

# Sync Zim framework modules
make sync-zimfw
```

## Architecture & Key Components

### Directory Structure
- `private_dot_config/` - Maps to `~/.config/` containing application configurations
  - `nvim/` - Neovim configuration using lazy.nvim
  - `alacritty/` - Alacritty terminal configuration
  - `emacs/` - Doom Emacs configuration
  - `SpaceVim.d/` - SpaceVim configuration
- `private_dot_local/` - Maps to `~/.local/` containing local data
  - `share/tmux/plugins/` - Tmux plugins managed by TPM
  - `share/zim/` - Zim framework modules
- `.chezmoiscripts/` - Scripts that run during chezmoi apply
- `.chezmoiexternal.toml` files - Define external dependencies to be fetched

### Key Configuration Files
- `chezmoi.toml.tmpl` - Chezmoi configuration template
- `Makefile` - Primary interface for common operations
- `dot_zshenv` - ZSH environment configuration

### Dependency Management
The repository uses `.chezmoiexternal.toml` files to manage external dependencies. These are automatically fetched and updated by chezmoi.

### Git Configuration
Chezmoi is configured with:
- Auto-commit enabled
- Auto-push enabled
- Uses nvim for merge conflicts

## Development Workflow

1. Make changes to files in the chezmoi source directory (`~/.local/share/chezmoi/`)
2. Use `chezmoi diff` to preview changes
3. Apply changes with `chezmoi apply -v`
4. Changes are automatically committed and pushed due to autoCommit/autoPush settings

## Syncthing Systemd User Unit

This repository includes a chezmoi script to manage the syncthing systemd user service on NixOS systems. The script:

1. Creates a symlink from `~/.config/systemd/user/syncthing.service` to `/run/current-system/sw/lib/systemd/user/syncthing.service`
2. Enables the service for automatic startup
3. Automatically updates the symlink when the Nix store path changes (e.g., after syncthing updates)

### Fix Broken Syncthing Symlink
If the syncthing service symlink is broken, run:
```bash
chezmoi apply
```

The script will automatically detect and fix the broken symlink, updating it to the current Nix store path.

## Important Notes

- This repository manages system configurations - be careful when applying changes
- The Makefile provides convenient targets for common operations
- External tools (tmux plugins, emacs packages, etc.) are synced separately from chezmoi apply
- Chezmoi scripts in `.chezmoiscripts/` run automatically during `chezmoi apply`
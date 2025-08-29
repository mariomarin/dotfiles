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

# Full sync (includes updating tmux plugins, zimfw)
make sync
```

### Tool-Specific Sync Commands
```bash
# Sync Zim framework modules
make sync-zimfw
```

### Tmux Plugin Management
Tmux plugins are now managed declaratively through chezmoi's external dependency system. All plugins are defined in `private_dot_local/share/tmux/plugins/.chezmoiexternal.toml` and are automatically downloaded/updated when running `chezmoi apply`.

Benefits:
- No more git conflicts in plugin directories
- Reproducible plugin versions
- Atomic updates with chezmoi
- No need to run TPM update commands

## Architecture & Key Components

### Directory Structure
- `private_dot_config/` - Maps to `~/.config/` containing application configurations
  - `nvim/` - Neovim configuration using lazy.nvim
  - `alacritty/` - Alacritty terminal configuration
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

#### Dynamic Version Management
External tools support dynamic version management:
- By default, tools use the latest GitHub release via `gitHubLatestRelease`
- Versions can be pinned in `.chezmoidata.toml`:
  ```toml
  [versions]
  containerUse = "v0.4.1"  # Pin specific version
  zimfw = "v1.17.0"        # Pin specific version
  ```
- Template files (`.chezmoiexternal.toml.tmpl`) check for pinned versions first

### Zsh Completions

#### Custom Zimfw Modules
To add completions for new tools:
1. Create a module directory: `private_dot_config/zim/modules/<tool-name>/`
2. Create `init.zsh` that generates completions dynamically
3. Add to `zimrc` BEFORE the completion module:
   ```zsh
   zmodule ${ZIM_CONFIG_FILE:h}/modules/<tool-name>
   ```

Example: The `container-use` module auto-generates completions for both `container-use` and `cu` commands.

#### Key Points for Zsh Completions
- Custom completion modules must load BEFORE zimfw's completion module
- Completions are generated dynamically when the tool binary changes
- Store completion files in the module's `functions/` subdirectory
- Add to `fpath` in the module's init.zsh

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

1. Resolves the system's syncthing service symlink to find the actual Nix store path
2. Creates a direct symlink from `~/.config/systemd/user/syncthing.service` to the resolved Nix store path (e.g., `/nix/store/.../syncthing.service`)
3. Enables the service for automatic startup
4. Automatically updates the symlink when the Nix store path changes (e.g., after syncthing updates)

### How it Works
- The script avoids fragile intermediate symlinks by resolving `/run/current-system/sw/lib/systemd/user/syncthing.service` to its actual target
- This makes the user service symlink point directly to the Nix store, making it more robust

### Fix Broken Syncthing Symlink
If the syncthing service symlink is broken, run:
```bash
chezmoi apply
```

The script will automatically detect and fix the broken symlink, updating it to the current Nix store path.

## Important Notes

- This repository manages system configurations - be careful when applying changes
- The Makefile provides convenient targets for common operations
- External tools (tmux plugins, etc.) are synced separately from chezmoi apply
- Chezmoi scripts in `.chezmoiscripts/` run automatically during `chezmoi apply`
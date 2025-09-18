# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## CRITICAL: Never Run These Commands

**NEVER** run these commands under any circumstances:

- `chezmoi purge` - This deletes the entire chezmoi source directory
- `chezmoi state reset` - This can cause chezmoi to lose track of ALL managed files
- Any command that deletes `.chezmoidata.db` or `chezmoistate.boltdb` files directly

These commands are destructive and will break the chezmoi configuration. A pre-commit hook is in place to block
these commands as an additional safety measure.

## Safe State Management Commands

These commands are SAFE to use when troubleshooting scripts:

- `chezmoi state delete-bucket --bucket=scriptState` - Clears state of run_once_ scripts (forces re-run)
- `chezmoi state delete-bucket --bucket=entryState` - Clears state of run_onchange_ scripts
- `chezmoi state delete --bucket=scriptState --key=script-name` - Clear specific script state

These only affect script execution tracking, not your actual files or configuration.

## Important Chezmoi Concepts

### Scripts and State Management

- **run_once_ scripts**: Run only once, state tracked in `scriptState` bucket
- **run_onchange_ scripts**: Run when their contents change, state tracked in `entryState` bucket
- Chezmoi stores whether and when scripts have run successfully in its persistent state
- To force re-run of ALL scripts:
  - `chezmoi state delete-bucket --bucket=scriptState` (for run_once_ scripts)
  - `chezmoi state delete-bucket --bucket=entryState` (for run_onchange_ scripts)

### Template Files

- Files ending in `.tmpl` are chezmoi templates
- Use `chezmoi execute-template` to test template rendering
- Edit templates with: `chezmoi edit path/to/file.tmpl`
- Common template variables:
  - `{{ .chezmoi.os }}` - Operating system (linux, darwin, windows)
  - `{{ .chezmoi.arch }}` - Architecture (amd64, arm64)
  - `{{ .chezmoi.homeDir }}` - User's home directory
  - Custom data from `.chezmoidata.toml`

### Debugging Templates

When a template fails to render:

1. Test with: `chezmoi execute-template < path/to/template.tmpl`
2. Check data with: `chezmoi data`
3. Verify syntax - common issues:
   - Missing closing braces `}}`
   - Undefined variables
   - Incorrect spacing around template directives

### Troubleshooting Ghost Scripts

If chezmoi complains about a non-existent script (e.g., "install-container-use.sh"):

1. Check managed files: `chezmoi managed | grep script-name`
2. Check state: `chezmoi state dump | grep script-name`
3. Clear specific script state: `chezmoi state delete --bucket=scriptState --key=script-name`
4. As a last resort, clear all script state: `chezmoi state delete-bucket --bucket=scriptState`
5. The issue often comes from renamed or moved scripts that are still tracked in state

## Shell Script Standards

### Always Use Portable Shebang

**ALWAYS** use `#!/usr/bin/env bash` as the shebang line for bash scripts:

- ✅ Correct: `#!/usr/bin/env bash`
- ❌ Incorrect: `#!/bin/bash`

This ensures scripts work across different systems where bash might be installed in different locations
(e.g., NixOS, macOS, Linux distributions).

### Script Template

```bash
#!/usr/bin/env bash
# Script description here

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Script content here
```

## Repository Overview

This is a chezmoi-managed dotfiles repository that uses templating and external data sources to manage system
configurations across different machines.

## Plugin and Package Management

### Update Strategy

The repository uses [topgrade](https://github.com/topgrade-rs/topgrade) for unified system updates. Topgrade
automatically detects and updates:

1. **System packages**: NixOS packages, Nix flakes
2. **Plugin managers**: Neovim (LazyVim), Tmux (TPM), Zim modules
3. **Programming tools**: npm/pnpm packages, Rust toolchain, Python packages
4. **Other tools**: Git repos, firmware (disabled by default)

### Automatic Updates

- Topgrade runs automatically after `chezmoi apply` to keep everything in sync
- Skip with: `CHEZMOI_SKIP_UPDATES=1 chezmoi apply` or `make quick-apply`
- Configuration in `private_dot_config/topgrade.toml`

### Manual Updates

```bash
# Update everything (system packages, plugins, tools)
make update

# Update only plugins (vim, tmux)
make update-plugins

# Update only system packages (nixos, nix)
make update-system

# Quick apply without running topgrade
make quick-apply
```

## Common Commands

### Chezmoi Operations

```bash
# Apply changes (includes topgrade updates)
chezmoi apply -v

# Quick apply without running topgrade
make quick-apply

# See what changes will be made
chezmoi diff

# Show status of managed files
chezmoi status
```

### NixOS Operations (Flakes)

```bash
# From repository root (using pattern rule):
make nixos              # Rebuild NixOS configuration (alias for nixos/switch)
make nixos/test         # Test configuration without switching
make nixos/boot         # Update boot configuration
make nixos/update       # Update flake inputs
make nixos/check        # Check flake configuration
make nixos/show         # Show flake metadata

# Or directly from nixos directory:
cd nixos && make        # Rebuild (switch is default)
cd nixos && make test   # Test configuration
```

### Configuration Management

```bash
# Neovim operations:
make nvim               # Sync plugins (alias for nvim/sync)
make nvim/clean         # Clean unused plugins
make nvim/health        # Check health

# Tmux operations:
make tmux               # Reload config (alias for tmux/reload)
make tmux/status        # Show tmux status
make tmux/health        # Check health

# Zim operations:
make zim                # Update modules (alias for zim/update)
make zim/compile        # Compile for faster loading
make zim/clean          # Clean cache
make zim/health         # Check health
```

Note: Plugin updates for all tools are handled by topgrade (`make update`)

### Tmux Plugin Management

Tmux plugins are now managed declaratively through chezmoi's external dependency system. All plugins are defined
in `private_dot_local/share/tmux/plugins/.chezmoiexternal.toml` and are automatically downloaded/updated when
running `chezmoi apply`.

Benefits:

- No more git conflicts in plugin directories
- Reproducible plugin versions
- Atomic updates with chezmoi
- No need to run TPM update commands

## Component-Specific Documentation

Detailed documentation for each major component is available in subdirectory CLAUDE.md and README files:

### CLAUDE.md Files (AI Guidance)

- [Neovim CLAUDE.md](private_dot_config/nvim/CLAUDE.md) - LazyVim setup, plugins, keymaps
- [NixOS CLAUDE.md](nixos/CLAUDE.md) - System configuration, modules, services
- [Zsh/Zim CLAUDE.md](private_dot_config/zim/CLAUDE.md) - Shell setup, completions, modules
- [Tmux CLAUDE.md](private_dot_config/tmux/CLAUDE.md) - **IMPORTANT: Update keybindings docs!**

### README Files (User Documentation)

- [Tmux README](private_dot_config/tmux/README.md) - Complete keybindings reference
- Additional component READMEs are created as needed

## ⚠️ Critical Documentation Rules

**When modifying tmux configuration:**

1. **ALWAYS** update the [Tmux README](private_dot_config/tmux/README.md) with keybinding changes
2. **ALWAYS** check for duplicate or conflicting keybindings
3. **ALWAYS** document plugin default keybindings
4. Refer to [Tmux CLAUDE.md](private_dot_config/tmux/CLAUDE.md) for detailed guidance

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

The repository uses `.chezmoiexternal.toml` files to manage external dependencies. These are automatically
fetched and updated by chezmoi.

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
2. Create `init.zsh` that generates completions dynamically using Bash-compatible syntax
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
- Use Bash-compatible code for Zimfw modules to ensure shfmt compatibility

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

## Development Environment Management

### Project-Specific Tools

**IMPORTANT**: Do NOT add linters, formatters, or development tools system-wide. Instead:

1. Each project should define its own development environment in a `devenv.nix` file
2. Use `direnv` with `direnv allow` to automatically load project-specific tools
3. This ensures reproducible development environments across different projects

### This Repository's Tools

The `devenv.nix` in this repository provides:

- **Nix**: nixpkgs-fmt, deadnix, statix, nil (LSP)
- **Lua**: stylua, lua-language-server (LSP)
- **Shell**: shellcheck, shfmt, bash-language-server (LSP)
- **JSON**: biome, vscode-langservers-extracted (LSP)
- **TOML**: taplo (formatter & LSP)
- **YAML**: yamlfmt, yaml-language-server (LSP)
- **Markdown**: markdownlint-cli, marksman (LSP)

To use these tools:

```bash
direnv allow  # Load the development environment
make format   # Format all files
make lint     # Lint all files
```

## Development Standards

- Follow conventional commit format with **SHORT** titles and descriptions
- Keep commit messages concise: title under 50 chars, description under 72 chars per line
- Use format: `type: brief description`
- Examples:
  - `fix: resolve tmux keybinding conflict`
  - `feat: add tmux.nvim for better integration`
  - `docs: update tmux keybindings README`

## NixOS Integration Patterns

### Syncthing Systemd User Unit

This repository includes a chezmoi script to manage the syncthing systemd user service on NixOS systems. The script:

1. Resolves the system's syncthing service symlink to find the actual Nix store path
2. Creates a direct symlink from `~/.config/systemd/user/syncthing.service` to the resolved Nix store path
   (e.g., `/nix/store/.../syncthing.service`)
3. Enables the service for automatic startup
4. Automatically updates the symlink when the Nix store path changes (e.g., after syncthing updates)

### Desktop Autostart Files

Similar to the syncthing approach, desktop autostart files are managed via a chezmoi script:

1. Links to system-installed desktop files from `/run/current-system/sw/share/applications/`
2. For files needing modifications (e.g., startup delays), creates modified copies
3. Automatically updates when packages are updated in NixOS
4. Removes obsolete autostart files

Current autostart applications:

- CopyQ (2s delay) - Clipboard manager
- Firefox (5s delay) - Web browser

### How it Works

- Scripts avoid fragile intermediate symlinks by resolving to actual Nix store paths
- This makes the configuration robust against package updates
- Run `chezmoi apply` to fix any broken symlinks after system updates

## Important Notes

- This repository manages system configurations - be careful when applying changes
- The Makefile provides convenient targets for common operations
- External tools (tmux plugins, etc.) are synced separately from chezmoi apply
- Chezmoi scripts in `.chezmoiscripts/` run automatically during `chezmoi apply`

## Neovim Configuration (LazyVim)

The repository uses LazyVim as the Neovim configuration framework:
See [Neovim CLAUDE.md](private_dot_config/nvim/CLAUDE.md) for detailed configuration.

### Claude Integration

- **Toggle**: `<leader>cc` opens Claude Code in a floating terminal
- **Continue**: `<leader>c.` continues the conversation
- **Reload**: `<leader>cr` reloads files modified by Claude
- Configuration in `private_dot_config/nvim/lua/plugins/claude.lua`

### Key Customizations

- Catppuccin colorscheme (mocha flavor)
- nvim-tree instead of neo-tree for file exploration
- Leap.nvim for navigation
- Chezmoi integration for dotfile management

### NixOS Compatibility

The configuration includes special handling for NixOS systems. See [NixOS CLAUDE.md](nixos/CLAUDE.md) for system
configuration details.

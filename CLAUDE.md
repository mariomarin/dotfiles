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

## Bootstrap Architecture

Understanding the bootstrap process is critical for maintaining this repository. Chezmoi executes setup in a
specific order, and placing code in the wrong phase will cause failures.

### Complete Execution Order

When you run `chezmoi init` or `chezmoi apply`, chezmoi executes these phases in order:

#### Phase 1: Bootstrap Scripts (`hooks.read-source-state.pre`)

- Runs **before** any templates are processed
- Installs tools that templates need to reference
- Must complete successfully or chezmoi aborts

#### Phase 2: Read Source State & Process Templates

- Chezmoi reads `.local/share/chezmoi` directory
- Processes all `.tmpl` files and evaluates template functions
- Can now use tools installed in Phase 1

#### Phase 3: Pre-Entry Scripts (`run_before_` scripts)

- Runs before files are applied
- Rarely used in this repository

#### Phase 4: Update Entries (files, directories, symlinks)

- Chezmoi creates/updates actual files in home directory
- Sets permissions and ownership

#### Phase 5: Change Scripts (`run_onchange_` scripts)

- Runs when script content changes
- **This is where declarative packages are installed**
- Scripts can be templates (processed in Phase 2)

#### Phase 6: Post-Entry Scripts (`run_after_` scripts)

- Runs after all files are applied
- Rarely used in this repository

### Pre-Hook Bootstrap System (Phase 1)

The repository uses chezmoi pre-hooks for OS-specific bootstrap **before reading source state**:

**Purpose:** Install critical dependencies before chezmoi reads templates

**Configuration in `private_dot_config/chezmoi/chezmoi.toml.tmpl`:**

```toml
[hooks.read-source-state.pre]
{{- if eq .chezmoi.os "windows" }}
    command = ".local/share/chezmoi/.bootstrap-windows.ps1"
{{- else }}
    command = ".local/share/chezmoi/.bootstrap-unix.sh"
{{- end }}
```

**Implementation:**

**`.bootstrap-unix.sh`** - Unix/macOS/Linux bootstrap:

- **macOS**: Installs Nix (Determinate Systems) → Bitwarden CLI via Nix profile
- **NixOS**: Detects NixOS and requires system-installed bitwarden-cli (no download, just verification)
- **Other Linux**: Suggests package manager install → Fallback: downloads latest static binary to ~/.local/bin

**`.bootstrap-windows.ps1`** - Windows bootstrap:

- Installs Bitwarden CLI via winget (auto-updates)
- Requires PowerShell (pre-installed on Windows)

**Critical patterns:**

- Scripts must be idempotent (exit fast if nothing to do)
- Windows script uses PowerShell (not bash - won't exist on fresh Windows)
- Run on every `chezmoi init` and `chezmoi apply` (fast due to early exits)
- macOS gets Nix for nix-darwin configuration management

### Decision Guide: Bootstrap vs Packages

**Use Bootstrap (Phase 1) if:**

- Templates reference this tool (e.g., `{{ bitwarden ... }}`, `{{ gitHubLatestRelease ... }}`)
- Tool is required for template processing (e.g., `jq` for parsing JSON in templates)
- Platform package manager needs installing (Homebrew, Nix)
- Failure to install would prevent chezmoi from reading source

**Use Packages YAML (Phase 5) if:**

- Regular development tool (git, neovim, direnv)
- Cross-platform shell (nushell for justfile scripting)
- Editor or terminal emulator
- Tool doesn't need to be available during template processing

**Examples:**

| Tool | Location | Reason |
|------|----------|--------|
| Bitwarden CLI | Bootstrap | Templates use `{{ bitwarden "id-rsa" }}` |
| jq | Bootstrap | Templates might parse JSON data |
| Homebrew (macOS) | Bootstrap | Needed to install other bootstrap tools |
| Nix (macOS) | Bootstrap | Required for nix-darwin system management |
| nushell | Packages | Used by justfiles, not templates |
| git | Packages | Regular dev tool, not needed by templates |
| neovim | Packages | Regular dev tool, not needed by templates |

### Declarative Package Management (Phase 5)

Packages are defined declaratively in `.chezmoidata/packages.yaml`:

```yaml
packages:
  darwin:
    brews: [git, neovim, direnv, just]
    casks: [alacritty]
  windows:
    winget: [Git.Git, Neovim.Neovim, direnv.direnv, casey.just, Alacritty.Alacritty]
```

**Installation via run_onchange scripts:**

- `.chezmoiscripts/run_onchange_darwin-install-packages.sh.tmpl` - macOS (homebrew)
- `.chezmoiscripts/run_onchange_windows-install-packages.ps1.tmpl` - Windows (winget)
- Scripts read from `.chezmoidata/packages.yaml` and install packages
- Run automatically during `chezmoi apply` when package list or script changes

**NixOS exception:** Packages managed via system configuration, not chezmoi

### Plugin and Package Management

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
just update

# Update only plugins (vim, tmux)
just update-plugins

# Update only system packages (nixos, nix)
just update-system

# Quick apply without running topgrade
just quick-apply
```

## Common Commands

See [README.md](README.md) for comprehensive command reference. Key workflows:

```bash
# Quick apply without topgrade updates
just quick-apply

# NixOS rebuild (see nixos/README.md for details)
just nixos

# Component operations (nvim, tmux, zim)
just <component>        # Default action for component
just <component>-health # Check component health

# Formatting and linting
just format             # Format all files
just lint               # Run all linting checks
```

**Note:** The repository uses `justfile` for task automation across all components.

## Component-Specific Documentation

Detailed documentation for each major component is available in subdirectory CLAUDE.md and README files:

### CLAUDE.md Files (AI Guidance)

- [Neovim CLAUDE.md](private_dot_config/nvim/CLAUDE.md) - LazyVim setup, plugins, keymaps
- [NixOS CLAUDE.md](nixos/CLAUDE.md) - System configuration, modules, services
- [Zsh/Zim CLAUDE.md](private_dot_config/zim/CLAUDE.md) - Shell setup, completions, modules
- [Tmux CLAUDE.md](private_dot_config/tmux/CLAUDE.md) - **IMPORTANT: Update keybindings docs!**
- [LeftWM CLAUDE.md](private_dot_config/leftwm/CLAUDE.md) - Window manager configuration
- [Polybar CLAUDE.md](private_dot_config/polybar/CLAUDE.md) - Status bar and scripts

### README Files (User Documentation)

- [Tmux README](private_dot_config/tmux/README.md) - Complete keybindings reference
- Additional component READMEs are created as needed

## ⚠️ Critical Documentation Rules

**When modifying tmux configuration:**

1. **ALWAYS** update the [Tmux README](private_dot_config/tmux/README.md) with keybinding changes
2. **ALWAYS** check for duplicate or conflicting keybindings
3. **ALWAYS** document plugin default keybindings
4. Refer to [Tmux CLAUDE.md](private_dot_config/tmux/CLAUDE.md) for detailed guidance

## Architecture

See [README.md](README.md) for directory structure, key files, and external dependency management.

### Zsh Configuration Preferences

See [private_dot_config/zsh/CLAUDE.md](private_dot_config/zsh/CLAUDE.md) and
[private_dot_config/zim/CLAUDE.md](private_dot_config/zim/CLAUDE.md) for detailed Zsh configuration guidance.

#### Code Style

- **Language**: Write proper zsh code, not bash
- **Approach**: Use functional middle ground approach
- **Control Flow**: Prefer early returns over nested conditionals
- **Error Handling**: Use `|| return` for command failures
- **Variables**: Always quote variables and use local scope
- **Functions**: Use descriptive names with hyphens (e.g., `sesh-sessions`)

### Git Configuration

Chezmoi is configured with:

- Auto-commit enabled
- Auto-push enabled
- Uses nvim for merge conflicts

### Bitwarden Integration

The repository uses Bitwarden CLI to manage secrets (SSH keys, API tokens, etc.) in chezmoi templates.

#### Setup

1. **Install Bitwarden CLI**:
   - **Automatic:** BW CLI auto-installs via pre-hook on first `chezmoi init`
   - **Manual:** Install via package manager if needed before running chezmoi

2. **Authenticate**:

   ```bash
   # Login to Bitwarden
   bw login <your-email>

   # Unlock vault (required before each use)
   bw unlock
   # Copy the export command shown and run it to set BW_SESSION
   ```

3. **Store SSH Keys in Bitwarden**:
   - Use CLI to create SSH Key item (type 5): `bw get template item | jq ...`
   - Or create via web vault/desktop app
   - See README.md for detailed CLI commands

#### Implementation Details (for AI)

**SSH Key Templates:**

- `private_dot_ssh/private_id_ed25519.tmpl` - Uses `{{ (bitwarden "item" "id-rsa").sshKey.privateKey }}`
- `private_dot_ssh/id_ed25519.pub.tmpl` - Uses `{{ (bitwarden "item" "id-rsa").sshKey.publicKey }}`

**SSH Key Item Type (type 5) structure:**

- `.sshKey.privateKey` - Private key content
- `.sshKey.publicKey` - Public key content
- `.sshKey.keyFingerprint` - Key fingerprint

**Session Management:**

- `make bw-unlock` - Unlocks vault, saves session to `.env` and `.envrc.local`
- `make bw-reload` - General direnv reload (happens to load BW_SESSION from `.envrc.local`)
- `.envrc` sources `.envrc.local` to load `BW_SESSION`
- Post-commit hook sources `.envrc.local` before running `chezmoi apply`
- Session persists until `bw lock` or `bw logout` (no auto-expiration)
- Note: `bw-reload` is not BW-specific, it's a convenience wrapper for `direnv allow && direnv reload`

**For detailed user documentation, see README.md "Bitwarden Integration" section.**

## Development Workflow

1. Make changes to files in the chezmoi source directory (`~/.local/share/chezmoi/`)
2. Use `chezmoi diff` to preview changes
3. Apply changes with `chezmoi apply -v`
4. Changes are automatically committed and pushed due to autoCommit/autoPush settings

## Development Environment Management

**IMPORTANT**: Do NOT add linters, formatters, or development tools system-wide. Instead:

1. Each project should define its own development environment in a `devenv.nix` file
2. Use `direnv` with `direnv allow` to automatically load project-specific tools
3. This ensures reproducible development environments across different projects

This repository uses `devenv.nix` for development tools. Use `make format` and `make lint` to format and check files.

### Formatting Tools Configuration

**CRITICAL**: Formatting tools are configured in TWO places that must be kept in sync:

1. **`devenv.nix` git hooks** (lines 52-135) - Automatic formatting on commit
   - Runs on **staged files only**
   - Fast, incremental
   - Pre-commit hooks

2. **`justfile` format targets** - Manual formatting
   - Runs on **entire repository**
   - For manual use outside git workflow
   - Useful for batch formatting

**When changing formatter arguments**, update BOTH locations:

Example - if changing shfmt arguments:

- `devenv.nix` line 74: `entry = lib.mkForce "shfmt -w -i 2 -ci -sr -kp";`
- `justfile`: `@shfmt -w -i 2 -ci -sr -kp .`

**Formatters to keep in sync**:

- nixpkgs-fmt (Nix files)
- stylua (Lua files)
- shfmt (Shell scripts) - **includes exclude patterns**
- shellcheck (Shell linting) - **includes exclude patterns**
- taplo (TOML files)
- yamlfmt (YAML files)
- markdownlint (Markdown files)

## Development Standards

- Follow conventional commit format with **SHORT** titles and descriptions
- Keep commit messages concise: title under 50 chars, description under 72 chars per line
- Use format: `type: brief description`
- Examples:
  - `fix: resolve tmux keybinding conflict`
  - `feat: add tmux.nvim for better integration`
  - `docs: update tmux keybindings README`

## User Services Management

We use two approaches for managing systemd user services:

- **NixOS Modules**: For system-wide services that all users need
- **Chezmoi Scripts**: For user-specific services and configurations

See [docs/USER_SERVICES.md](docs/USER_SERVICES.md) for detailed comparison and guidelines.

## NixOS Integration

See [docs/USER_SERVICES.md](docs/USER_SERVICES.md) for details on systemd user service management.

NixOS-specific integration is handled via chezmoi scripts that resolve system paths and create robust symlinks.
Run `chezmoi apply` after system updates to fix any broken symlinks.

## Important Notes

- This repository manages system configurations - be careful when applying changes
- The justfile provides convenient targets for common operations
- External tools (tmux plugins, etc.) are synced separately from chezmoi apply
- Chezmoi scripts in `.chezmoiscripts/` run automatically during `chezmoi apply`

## Code Style and Linting

### Markdown Files

- **Always specify language for fenced code blocks** to pass markdownlint checks
- Use `text` for directory structures, terminal output, or plain text
- Use appropriate language identifiers (`bash`, `zsh`, `nix`, `yaml`, etc.) for code
- Example:

  ````markdown
  ```text
  directory/structure/
  ```
  
  ```bash
  echo "shell commands"
  ```
  ````

## Neovim Configuration

See [private_dot_config/nvim/CLAUDE.md](private_dot_config/nvim/CLAUDE.md) for detailed configuration and
[README.md](README.md) for feature overview.

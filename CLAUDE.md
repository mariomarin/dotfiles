# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Documentation Style

**IMPORTANT**: When creating README or documentation files:

- ✅ **Be concise** - Focus on essential information only
- ✅ **Use tables** - Condense information into tables when possible
- ✅ **Short examples** - One or two examples max, not exhaustive
- ✅ **External links** - Link to official docs instead of reproducing them
- ❌ **Avoid verbosity** - No need for comprehensive guides
- ❌ **No repetition** - Don't explain the same thing multiple ways
- ❌ **No obvious info** - Skip what users can infer from context

**Good example**: "Start SSH tunnel: `just tunnel-ssh`. See `just tunnel-help` for all options."

**Bad example**: Multiple paragraphs explaining every flag, every use case, every platform, etc.

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

## Architecture Decisions

### Chezmoi over Home Manager

This repository uses **chezmoi** for dotfile management instead of home-manager:

- Chezmoi handles cross-platform dotfiles (NixOS, macOS, Windows)
- Nix/nix-darwin/NixOS manage system packages and services
- No home-manager - prefer chezmoi's templating and external data sources

**Do NOT suggest home-manager** for:

- Dotfile management (use chezmoi)
- User-level configuration (use chezmoi templates)
- Per-user packages (use nix profile or system packages)

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

### Avoid Template Abuse

**Prefer runtime detection over chezmoi templates** for platform differences:

| Instead of | Use |
| ---------- | --- |
| `{{ if eq .chezmoi.os "darwin" }}...{{ end }}` in every file | `.chezmoiignore` for platform filtering |
| Templates just to swap one value | Runtime if-shell or env detection |
| Complex template logic | Separate config files per platform |

**Examples:**

```bash
# ❌ Template abuse - chezmoi template for runtime value
set -g @fingers-ctrl-action '{{ if eq .chezmoi.os "darwin" }}open{{ else }}xdg-open{{ end }}'

# ✅ Runtime detection - tmux if-shell
if-shell "uname | grep -q Darwin" "set -g @fingers-ctrl-action 'open'"
if-shell "uname | grep -q Linux" "set -g @fingers-ctrl-action 'xdg-open'"

# ✅ Platform filtering - use .chezmoiignore
# In .chezmoiignore:
{{ if ne .chezmoi.os "darwin" }}
.config/hammerspoon
{{ end }}
```

### Script Language Preference

**Prefer Nushell over Bash** for chezmoi scripts (except `.install/` bootstrap):

| Script Type | Language | Reason |
| ----------- | -------- | ------ |
| `.install/*.sh` | Bash/POSIX | Must run before nushell is installed |
| `.chezmoiscripts/*.nu` | Nushell | Validated by git hooks, better data handling |
| Complex package install | Nushell | Native YAML/JSON parsing with `open` |

**Benefits of Nushell scripts:**

- Validated by `nushell-check` pre-commit hook
- Native YAML/JSON parsing (`open file.yaml`)
- Better error handling and pipelines
- Structured data throughout

### Debugging Templates

When a template fails to render:

1. Test with: `chezmoi execute-template < path/to/template.tmpl`
2. Check data with: `chezmoi data`
3. Verify syntax - common issues:
   - Missing closing braces `}}`
   - Undefined variables
   - Incorrect spacing around template directives

### Managing Directories with User Content

**Prefer `.keep` files and `.chezmoiignore` over shell scripts for directory creation:**

```bash
# ✅ Good - declarative approach
# 1. Create directory in source with .keep file
mkdir -p $(chezmoi source-path)/Pictures/Wallpapers
touch $(chezmoi source-path)/Pictures/Wallpapers/.keep

# 2. Add to .chezmoiignore to ignore contents
Pictures/Wallpapers/**
!Pictures/Wallpapers/.keep

# ❌ Avoid - imperative script approach
mkdir ~/Pictures/Wallpapers  # in run_once script
```

**When to use this pattern:**

- User-managed directories (wallpapers, downloads, custom apps)
- Directories that should exist but contents vary by machine
- XDG directories like `~/.config/autostart`, `~/.local/share/applications`

**Benefits:**

- Declarative and version controlled
- No need for shell scripts
- Clearer intent - directory structure is part of dotfiles

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

### Script Code Style

**Prefer early returns over nested conditionals** to reduce nesting and improve readability.

## Nushell and Justfile Standards

General Nushell syntax and idioms come from the vendored
[`nushell` skill](.claude/skills/nushell/SKILL.md). The rules below are repo-specific and win on conflict
(e.g. `^` prefix only for commands that shadow builtins).

### Extract Complex Nushell Code to `.nu` Files

**IMPORTANT**: Justfiles with embedded Nushell code (`#!/usr/bin/env nu`) are NOT validated by git hooks.

**Problem**: The `nushell-check` pre-commit hook only runs on files ending in `.nu`, not justfiles.

**Solution**: Extract significant Nushell code to standalone `.nu` files.

### When to Extract Nushell Code

✅ **Extract to `.nu` file when**:

- Recipe has >10 lines of Nushell code
- Recipe contains complex logic (loops, conditionals, error handling)
- Recipe has commands that need syntax validation
- Similar to existing patterns (`.scripts/bw.nu`, `nix/darwin/darwin.nu`)

❌ **Keep inline when**:

- Recipe is <5 lines
- Simple command wrapper with no logic
- Print statements only

### How to Extract

**Before** (inline in justfile):

```just
health:
    #!/usr/bin/env nu
    print "Health Check"
    let result = (do { command } | complete)
    # ... 20 more lines of complex logic
```

**After** (extracted to `.nu` file):

```just
# justfile
health:
    nu component.nu health
```

```nu
# component.nu
def "main health" [] {
    print "Health Check"
    let result = (do { ^command } | complete)
    # ... validated by git hooks!
}
```

### Nushell Syntax Rules

**Never mix Just template variables with Nushell string interpolation**:

```nu
# ❌ Wrong - Nushell tries to execute HOST as command
let config = $".#({{HOST}})"

# ✅ Correct - Just substitutes before Nushell sees it
let config = ".#{{HOST}}"

# ✅ Best - Pass as parameter to .nu script
# justfile: nu script.nu {{HOST}}
# script.nu: def main [host: string] { let config = $".#($host)" }
```

**Only use `^` prefix for commands that shadow Nushell builtins**:

```nu
# ❌ Unnecessary - bw is not a Nushell builtin
^bw unlock

# ✅ Correct - bw doesn't shadow anything
bw unlock

# ✅ Correct - uname does shadow Nushell's uname
^uname -m

# ✅ Correct - nix doesn't shadow, but good for clarity in complex scripts
^nix build
```

**Check if a command shadows Nushell builtins**:

```bash
nu -c "help commands | where name == 'command-name'"
```

### Examples in This Repository

| Component  | Extracted File                   | Justfile                 |
| ---------- | -------------------------------- | ------------------------ |
| Darwin     | `nix/darwin/darwin.nu`           | `nix/darwin/justfile`    |
| Bitwarden  | `.scripts/bw.nu`                 | `justfile`               |
| Cloudflare | `.scripts/cloudflare-tunnel.nu`  | `justfile`               |

### Nushell Code Style

**Prefer idiomatic patterns:**

| Avoid | Prefer |
| ----- | ------ |
| `try { } catch { bool }` | Return `null`, check `is-empty` |
| Nested `if/else` | Guard clauses with early `return` |
| Boolean flags | Return value or `null` |
| Exit codes everywhere | `{ ok: bool, error?: string }` records |
| Imperative loops | `each`, `where`, `reduce` pipelines |
| Verbose success output | Unix rule of silence: only print on error |

**Examples:**

```nu
# ✅ Return null for "not found" instead of throwing
def find-task [name: string] {
    let result = (do { schtasks /Query /TN $name } | complete)
    if $result.exit_code == 0 { $name } else { null }
}

# ✅ Use is-empty/is-not-empty or default
let task = (find-task "Kanata" | default "FallbackTask")

# ✅ Early return instead of nested if
def restart-if-exists [name: string] {
    let task = (find-task $name)
    if ($task | is-empty) { return }
    restart-task $task
}

# ✅ Pipelines over intermediate variables
$path | validate-exists | read-config | apply-settings
```

**Naming conventions:**

| Pattern | Naming | Example |
| ------- | ------ | ------- |
| Lookup (may fail) | `find-*` | `find-task`, `find-service` |
| Predicate | `is-*`, `has-*` | `is-running`, `has-config` |
| Action | verb | `stop-kanata`, `restart-service` |

## Repository Overview

This is a chezmoi-managed dotfiles repository that uses templating and external data sources to manage system
configurations across different machines.

## Machine Configuration and Platform Detection

### Automatic Platform Detection

Platform is auto-detected from environment, no hostname configuration needed:

| Detection | Platform | Description |
| --------- | -------- | ----------- |
| Darwin | `darwin` | Mac with nix-darwin |
| Linux + NixOS (`osRelease.id`) | `nixos` | NixOS system |
| Linux + WSL | `nixos-wsl` | NixOS on WSL |
| Linux + other | `linux-apt` | Codespaces, devcontainers (no Nix, no root) |
| Windows | `windows` | Native Windows |

### For NixOS: Setting Hostname

NixOS machines need a hostname for nix-darwin/NixOS configuration:

```bash
# Set hostname in NixOS configuration.nix
networking.hostName = "symbiont";

# Or set temporarily before chezmoi init
export HOSTNAME=symbiont && chezmoi init --force
```

Known Nix hostnames: `malus`, `symbiont`

### Feature Flags

Features are auto-detected but can be overridden in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data.machineConfig.features]
    kanata = false      # Disable keyboard remapping
    desktop = true      # Force desktop mode
    audio = false       # Disable audio config
```

**Auto-detection rules:**

| Feature | Enabled when |
| ------- | ------------ |
| `kanata` | Desktop + not WSL + not codespaces |
| `desktop` | Darwin or Windows (all Linux hosts are headless) |
| `audio` | Desktop + not WSL + not codespaces |

### Template Variables

- `{{ .machineConfig.platform }}` - Platform type (darwin, nixos, nixos-wsl, linux-apt, windows)
- `{{ .machineConfig.hostname }}` - System hostname
- `{{ .machineConfig.features.desktop }}` - Has GUI
- `{{ .machineConfig.features.kanata }}` - Uses Kanata keyboard remapping

### Troubleshooting

**Check current config:**

```bash
chezmoi data | grep -A10 machineConfig
```

**Force re-detection:**

```bash
chezmoi init --force
```

## Bootstrap Architecture

Understanding the bootstrap process is critical for maintaining this repository. Chezmoi executes setup in a
specific order, and placing code in the wrong phase will cause failures.

### Complete Execution Order

When you run `chezmoi init` or `chezmoi apply`, chezmoi executes these phases in order:

#### Phase 1: Bootstrap (manual, see below)

- Runs **before** the first `chezmoi init`
- Installs tools that templates need to reference

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

### Bootstrap (before chezmoi)

There is no chezmoi pre-hook: run the bootstrap once by hand (see [.install/README.md](.install/README.md)).

| Script | Platforms | Does |
| ------ | --------- | ---- |
| `.install/bootstrap-unix.sh` | darwin, nixos, linux-apt | Nix + Homebrew (darwin), Bitwarden via `.install/shell.nix`, or chezmoi only (linux-apt) |
| `.install/bootstrap-windows.ps1` | windows | winget, git, chezmoi, nu, bw, just, yq |
| `install.sh` (repo root) | Codespaces/devcontainers | Installs chezmoi to `~/.local/bin`, runs `chezmoi init --apply` |

Bootstrap only installs what templates need (Bitwarden, `gitHubLatestRelease` access) and the package manager.

### Packages (Phase 4/5)

| Platform | Source of truth | Applied by |
| -------- | --------------- | ---------- |
| NixOS / nixos-wsl | `nix/nixos/` + `nix/common/modules/` | `run_onchange_nixos-rebuild.nu.tmpl`, `just nixos` |
| darwin | `nix/darwin/` + `nix/common/modules/` | `run_onchange_darwin-rebuild.nu.tmpl`, `just darwin` |
| windows | `private_dot_config/winget/configuration.dsc.yaml` | `run_onchange_after_windows-install-packages.nu.tmpl` |
| linux-apt | `private_dot_local/bin/.chezmoiexternal.toml.tmpl` (release binaries) | chezmoi externals |

### Plugin and Package Management

### Update Strategy

The repository uses [topgrade](https://github.com/topgrade-rs/topgrade) for unified system updates. Topgrade
automatically detects and updates:

1. **System packages**: NixOS packages, Nix flakes
2. **Plugin managers**: Neovim (LazyVim), Tmux (TPM), Zim modules
3. **Programming tools**: npm packages, Rust toolchain, Python packages
4. **Other tools**: Git repos, firmware (disabled by default)

### Pinned Versions

Most dependencies are rolling (`gitHubLatestRelease`, git-repo externals, lockfiles).
Anything pinned without a lockfile is bumped by [updatecli](https://www.updatecli.io/)
manifests in `updatecli/updatecli.d/`, run by `update-deps.yml` (needs an `UPDATECLI_TOKEN` PAT with
`workflow` scope). Preview locally: `just updatecli-diff`. When adding a pin, add a target there.

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

### Keybindings Documentation

- [docs/keybindings.md](docs/keybindings.md) - **Unified index, check here for conflicts first**

## ⚠️ Critical Documentation Rules

**When modifying any keybindings:**

1. **ALWAYS** check [docs/keybindings.md](docs/keybindings.md) for conflicts first
2. **ALWAYS** update the conflict guide in docs/keybindings.md if adding root-level keys
3. Refer to [Tmux CLAUDE.md](private_dot_config/tmux/CLAUDE.md) for tmux-specific guidance

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

- `private_dot_ssh/private_id_ed25519.tmpl` - Uses `{{ (bitwarden "item" "id_ed25519").sshKey.privateKey }}`
- `private_dot_ssh/id_ed25519.pub.tmpl` - Uses `{{ (bitwarden "item" "id_ed25519").sshKey.publicKey }}`

**SSH Key Item Type (type 5) structure:**

- `.sshKey.privateKey` - Private key content
- `.sshKey.publicKey` - Public key content
- `.sshKey.keyFingerprint` - Key fingerprint

**Session Management:**

- `just bw-unlock` - Unlocks vault, saves session to `.env.local`
- `just bw-reload` - Reloads direnv (loads BW_SESSION from `.env.local` and validates session)
- `.envrc` uses `dotenv_if_exists` to load `.env.local`
- `justfile` uses `set dotenv-load` to auto-load `.env.local` in all targets
- Post-commit hook sources environment before running `chezmoi apply`
- Session persists until `bw lock` or `bw logout` (no auto-expiration)
- Session validation runs during reload to detect expired sessions

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

### Claude Code Integration

The repository uses devenv.sh's Claude Code integration for safety and workflow enhancement:

**Command Validation (PreToolUse Hook):**

- Blocks dangerous commands before execution
- Configured in `devenv.nix` under `claude.code.hooks.PreToolUse.Bash`
- Protected commands:
  - `chezmoi purge` - Would delete entire chezmoi source directory
  - `chezmoi state reset` - Would cause chezmoi to lose track of all managed files
  - Direct deletion of state files (`chezmoistate.boltdb`, `.chezmoidata.db`)
- Provides helpful error messages with safe alternatives
- Example: Suggests `chezmoi state delete-bucket --bucket=scriptState` instead of full reset

This integration ensures AI assistants can't accidentally execute destructive commands.

## Development Standards

### Commit Practices

- **Make small, focused commits frequently** - Don't batch multiple unrelated changes
- Follow conventional commit format with **SHORT** titles and descriptions
- Keep commit messages concise: title under 50 chars, description under 72 chars per line
- **No AI footers** - Do NOT add "Generated with Claude Code" or "Co-Authored-By: Claude" to commits
- Use format: `type: brief description`
- Examples:
  - `fix: resolve tmux keybinding conflict`
  - `feat: add tmux.nvim for better integration`
  - `docs: update tmux keybindings README`
  - `refactor: remove .tmpl from non-template scripts`

### Code Removal

When removing code, configuration, or features:

- **Delete completely** - Don't leave tombstone comments like `# X is now in Y` or `# removed`
- **No migration breadcrumbs** - Comments explaining where something moved become stale noise
- **Git history is the record** - Use `git log` or `git blame` to find removed code, not comments
- **Clean deletions** - If something is unused, remove it entirely without explanation

## User Services Management

We use two approaches for managing systemd user services:

- **NixOS Modules**: For system-wide services that all users need
- **Chezmoi Scripts**: For user-specific services and configurations

See [docs/USER_SERVICES.md](docs/USER_SERVICES.md) for detailed comparison and guidelines.

## Cross-Platform Font Management

Nerd Fonts are installed on desktop platforms for Unicode symbols (⎋ ⭾ ⇪ ⌫ ⏎ ␣ etc.) used in kanata configs and terminals.

| Platform | Location | Font Package |
| -------- | -------- | ------------ |
| macOS | `nix/common/modules/fonts.nix` | `nerd-fonts.*` from nixpkgs |
| Windows | `private_dot_config/winget/configuration.dsc.yaml` | `DEVCOM.JetBrainsMonoNerdFont` |

**Core fonts** (shared via `nix/common/modules/fonts.nix`):

- `nerd-fonts.jetbrains-mono` - Primary monospace font
- `nerd-fonts.iosevka` - Alternative monospace
- `nerd-fonts.symbols-only` - Standalone symbols fallback

**Adding fonts**: Update the common module for macOS, or winget DSC for Windows.
Linux hosts are headless (WSL uses Windows fonts).

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

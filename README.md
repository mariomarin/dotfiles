# Dotfiles

This is a chezmoi-managed dotfiles repository that uses templating and external data sources to manage system
configurations across different machines.

## Quick Start

### NixOS (Fresh Install)

```bash
# 1. Clone dotfiles
git clone https://github.com/mariomarin/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi

# 2. First-time NixOS setup (enables flakes and applies configuration)
just nixos/first-time

# 3. Future updates
just nixos
```

### macOS

```bash
# 1. Install chezmoi
brew install chezmoi

# 2. Initialize (auto-installs Homebrew, Nix, Bitwarden CLI)
chezmoi init https://github.com/mariomarin/dotfiles.git

# 3. Login to Bitwarden and apply
bw login
export BW_SESSION=$(bw unlock --raw)
chezmoi apply
```

### Windows

```bash
# 1. Install Git and chezmoi
winget install Git.Git
winget install twpayne.chezmoi

# 2. Initialize (auto-installs Bitwarden CLI)
chezmoi init https://github.com/mariomarin/dotfiles.git

# 3. Login to Bitwarden and apply
bw login
$env:BW_SESSION = bw unlock --raw
chezmoi apply
```

## Directory Structure

This repository uses [chezmoi's naming conventions](https://www.chezmoi.io/reference/source-state-attributes/), which
makes directories look unusual at first glance:

```text
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

## Bootstrap Process

When you run `chezmoi init` or `chezmoi apply` for the first time, chezmoi executes several steps in a specific
order. Understanding this order helps you know where to place different types of setup logic.

### Execution Order

1. **Bootstrap Scripts** (`hooks.read-source-state.pre`)
   - Runs **before** templates are processed
   - Installs tools that templates need to reference
   - OS-specific: `.bootstrap-unix.sh` (macOS/Linux) or `.bootstrap-windows.ps1` (Windows)

2. **Template Processing**
   - Chezmoi reads the source directory and processes all `.tmpl` files
   - Templates can reference tools installed in step 1
   - Example: `{{ bitwarden "id-rsa" }}` requires `bw` CLI from bootstrap

3. **Package Installation** (`run_onchange_` scripts)
   - Installs regular development tools declaratively
   - Defined in `.chezmoidata/packages.yaml`
   - Examples: git, neovim, nushell, just, direnv

4. **File Application**
   - Chezmoi creates/updates files and directories
   - Sets correct permissions and ownership

### What Goes Where?

**Bootstrap Scripts** (step 1):

- Bitwarden CLI (templates use `{{ bitwarden ... }}`)
- Platform package managers (Homebrew on macOS)
- Nix package manager (for nix-darwin on macOS)
- Tools required by template processing

**Package YAML** (step 3):

- Regular development tools (git, neovim, direnv)
- Cross-platform shells (nushell for justfile scripting)
- Editor and terminal emulators
- Tools that don't need to be available during template processing

### Platform-Specific Bootstrap

**macOS** (`.bootstrap-unix.sh`):

1. Install Homebrew if missing
2. Install Nix for nix-darwin support
3. Install Bitwarden CLI via Homebrew

**Linux** (`.bootstrap-unix.sh`):

- Install Bitwarden CLI only
- NixOS: System packages managed via `just nixos/first-time`

**Windows** (`.bootstrap-windows.ps1`):

- Install Bitwarden CLI via winget
- Uses PowerShell (fresh Windows doesn't have bash)

### Why This Matters

- **Templates fail without bootstrap**: If a template uses `{{ bitwarden ... }}` but `bw` isn't installed,
  chezmoi fails
- **Packages can use templates**: Package installation scripts are processed as templates
- **Bootstrap runs every time**: `hooks.read-source-state.pre` executes on every `chezmoi apply` (but scripts
  check if tools are already installed)

## Common Tasks (justfile)

```bash
# List all available commands
just --list

# Apply dotfiles (default command)
just               # Same as: just quick-apply

# Apply changes verbosely
just apply

# Quick apply without topgrade updates
just quick-apply

# Preview changes before applying
just diff

# Bitwarden session management
just bw-unlock     # Unlock vault and save session
just bw-reload     # Reload direnv (loads BW_SESSION from .envrc.local)

# Development tasks
just format        # Format all files (Lua, Nix, Shell, YAML, Markdown)
just lint          # Run all linting checks
just check         # Run all checks

# System health
just health        # Quick health summary
just health-all    # Detailed health checks for all subsystems

# Component updates
just update        # Update everything (via topgrade)
just nixos         # NixOS rebuild
just nvim          # Sync Neovim plugins
just tmux          # Reload tmux config
just zim           # Update Zim modules
```

**Note:** Component-specific Makefiles (nvim, tmux, etc.) are still available for advanced operations.

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

## Quick Start: Windows

**First-time setup on Windows:**

```powershell
# Install Git and chezmoi via winget
winget install Git.Git
winget install twpayne.chezmoi

# Restart PowerShell, then initialize dotfiles
chezmoi init https://github.com/mariomarin/dotfiles.git

# Bitwarden CLI is auto-installed by chezmoi pre-hook
# Login to Bitwarden
bw login

# Unlock and set session
$env:BW_SESSION = bw unlock --raw

# Apply dotfiles (packages auto-install, SSH keys fetched from Bitwarden)
chezmoi apply -v
```

**What happens automatically:**

- ✅ Bitwarden CLI installs via pre-hook (before reading templates)
- ✅ Packages install via `run_onchange_` scripts (Git, Neovim, direnv, just, Alacritty)
- ✅ SSH keys fetch from Bitwarden vault

## Bitwarden Integration

This repository uses Bitwarden to securely store and manage secrets like SSH keys.

### Setup

**Create SSH Key item in Bitwarden (CLI method):**

```bash
# Encode your SSH keys and create the item
bw get template item | jq \
  '.type = 5 | .name = "id-rsa" | .sshKey = {
    "privateKey": "'$(cat ~/.ssh/id_ed25519)'",
    "publicKey": "'$(cat ~/.ssh/id_ed25519.pub)'"
  }' | bw encode | bw create item

# Or use the web vault if you prefer a GUI
```

**Alternative: Web vault method:**

1. Open Bitwarden web vault
2. Create new **SSH Key** item named `id-rsa`
3. Paste keys in respective fields

### Usage

**Quick workflow:**

```bash
# 1. Unlock vault and save session
make bw-unlock

# 2. Reload environment to load session
make bw-reload

# 3. Apply dotfiles (SSH keys are fetched from Bitwarden)
make
```

**Manual workflow (Unix):**

```bash
# Unlock and export session
export BW_SESSION=$(bw unlock --raw)

# Apply dotfiles
chezmoi apply -v
```

**Manual workflow (Windows):**

```powershell
# Unlock and export session in PowerShell
$env:BW_SESSION = bw unlock --raw

# Apply dotfiles
chezmoi apply -v
```

**Note:** On Windows, `direnv` is available but `devenv.nix` (which provides the `make` targets) is not.
Use the manual PowerShell workflow above instead of `make` commands.

### How It Works

- SSH key templates fetch keys from Bitwarden using the `bitwarden` template function
- `make bw-unlock` saves session token to `.envrc.local` (ignored by git)
- `make bw-reload` reloads direnv, which sources `.envrc.local` and loads `BW_SESSION`
- Session persists until you run `bw lock` or `bw logout`
- Note: `bw-reload` is a general direnv reload command, not BW-specific

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

### LazyVim Features

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

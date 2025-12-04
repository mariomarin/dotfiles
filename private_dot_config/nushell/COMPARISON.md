# Zsh vs Nushell Feature Comparison

This document compares the current zsh/zim setup with Nushell equivalents.

## Current Zsh Modules and Nushell Status

| Zsh Feature | Status | Nushell Equivalent | Notes |
|-------------|--------|-------------------|-------|
| **Core Shell Features** ||||
| environment | ✅ Built-in | Native Nushell | Environment handling is native |
| input (keybindings) | ✅ Configured | config.nu keybindings | Vi mode configured |
| termtitle | ✅ Built-in | Native support | Nushell sets terminal title automatically |
| **Prompt** ||||
| prompt-pwd | ✅ Configured | oh-my-posh | Smart path truncation built-in |
| git-info | ✅ Configured | oh-my-posh | Git status in prompt |
| gitster theme | ✅ Configured | oh-my-posh catppuccin_mocha | Similar minimal aesthetic |
| **Alternatives** | - | starship, powerline.nu, panache-git | Other prompt options |
| **Enhancements** ||||
| syntax-highlighting | ✅ Built-in | Native | Nushell has native syntax highlighting |
| autosuggestions | ✅ Built-in | Native completion | Built into completion system |
| history-search | ✅ Configured | atuin + native | Atuin integrated, Ctrl+R works |
| vi-mode | ✅ Configured | config.nu | Comprehensive vi mode setup |
| **Directory Navigation** ||||
| zoxide | ✅ Configured | zoxide integration | Smart cd with frecency |
| fzf | ⚠️ Partial | nu_plugin_skim | Need to install plugin for fuzzy selection |
| **Git Tools** ||||
| git module | ⚠️ Missing | git.nu script | Need to add git utility scripts |
| git-branchless | ❌ Completions only | Custom completions | Need completions for git-branchless |
| | - | git-aliases.nu | Convenient git shortcuts available |
| | - | git_gone.nu | Clean merged branches |
| | - | nu_plugin_gstat | Git status plugin |
| **Utilities** ||||
| utility (colored ls/grep) | ✅ Built-in | Native | Nushell has colored output natively |
| exa | ✅ System | Use eza/lsd from system | Or native ls command |
| **Completions** ||||
| zsh-completions | ✅ Configured | carapace-bin | Multi-shell completion engine |
| container-use | ❌ Need custom | Custom completions | Need to create .nu completions |
| aws-sso-cli | ❌ Need custom | Custom completions | Need to create .nu completions |
| **Development Tools** ||||
| atuin | ✅ Configured | atuin.nu | Shell history sync/search |
| wakatime | ❌ Missing | Unknown | Need to check wakatime nu support |
| **Session Management** ||||
| sesh (tmux) | ⚠️ Check compat | Need to verify | Sesh may work with nu |
| **Custom Helpers** ||||
| claude-helpers | ❌ Need port | Custom .nu scripts | Need to port zsh functions to nu |

## Recommended Additions

### High Priority

1. **nu_plugin_skim** - Fuzzy selection within nushell
   - Provides interactive fuzzy finding like fzf
   - Use: `open file.json | skim`

2. **git.nu** - Git utilities script
   - Convenient git operations
   - Repository navigation helpers

3. **nu_plugin_clipboard** - System clipboard integration
   - Better copy/paste support
   - Cross-platform clipboard access

4. **docker.nu / kubernetes.nu** - Container management scripts
   - If you work with containers/k8s
   - Convenient wrappers for docker/kubectl

### Medium Priority

1. **git-aliases.nu** - Git command shortcuts
   - Common git operations aliased
   - Faster workflow

2. **nu-dir-bookmark** - Directory bookmarks
   - Quick directory jumps
   - Alternative to zoxide for specific locations

3. **cargo_search.nu** - Cargo package search
   - If you work with Rust
   - Quick package lookup

4. **todo.nu** - Task management
   - CLI todo list
   - Integrates with nushell

### Low Priority

1. **nu_plugin_plot** / **nu_plugin_termplot** - Terminal plotting
   - Visualize data in terminal
   - Useful for data analysis

2. **nufetch** - System information display
   - Neofetch-style system info
   - Written in nushell

3. **nu_plugin_desktop_notifications** - System notifications
   - Send desktop notifications
   - Useful for long-running commands

## Missing Features (No Nushell Equivalent)

1. **zsh-history-substring-search** - Nushell has different history search
   - Use Ctrl+R for history search
   - Or up/down arrows for command history

2. **wakatime-zsh-plugin** - Unknown if wakatime supports nushell
   - May need to use wakatime CLI directly
   - Or create custom integration

## Installation Guide

### Plugins

Install nushell plugins via cargo:

```bash
# Fuzzy selection
cargo install nu_plugin_skim
plugin add ~/.cargo/bin/nu_plugin_skim

# Clipboard support
cargo install nu_plugin_clipboard
plugin add ~/.cargo/bin/nu_plugin_clipboard

# Git status
cargo install nu_plugin_gstat
plugin add ~/.cargo/bin/nu_plugin_gstat
```

### Scripts

Download scripts to `~/.config/nushell/scripts/`:

```bash
cd ~/.config/nushell
mkdir -p scripts

# Git utilities
wget https://raw.githubusercontent.com/nushell/nu_scripts/main/modules/git/git.nu -O scripts/git.nu
wget https://raw.githubusercontent.com/nushell/nu_scripts/main/modules/git/git-aliases.nu -O scripts/git-aliases.nu

# Docker utilities (if needed)
wget https://raw.githubusercontent.com/nushell/nu_scripts/main/modules/docker/docker.nu -O scripts/docker.nu

# Kubernetes utilities (if needed)
wget https://raw.githubusercontent.com/nushell/nu_scripts/main/modules/kubernetes/kubernetes.nu -O scripts/kubernetes.nu
```

Then source in `config.nu`:

```nu
# Git utilities
use ~/.config/nushell/scripts/git.nu *
use ~/.config/nushell/scripts/git-aliases.nu *
```

## Custom Completions

For tools like container-use, aws-sso-cli, git-branchless, create completion files:

```bash
# Generate completions if tool supports it
container-use completions nushell > ~/.config/nushell/completions/container-use.nu
aws-sso-cli completions nushell > ~/.config/nushell/completions/aws-sso-cli.nu

# Or use carapace
carapace container-use nushell
```

## Migration Checklist

- [x] Vi mode configured
- [x] Prompt (oh-my-posh) configured
- [x] History (atuin) integrated
- [x] Directory navigation (zoxide) integrated
- [x] Completions (carapace) integrated
- [ ] Install nu_plugin_skim for fuzzy selection
- [ ] Add git utility scripts (git.nu, git-aliases.nu)
- [ ] Port claude-helpers to nushell scripts
- [ ] Create custom completions for tools
- [ ] Verify sesh compatibility with nushell
- [ ] Check wakatime nushell support
- [ ] Add clipboard plugin if needed
- [ ] Add container/k8s scripts if needed

## Notes

- Nushell's native features replace many zsh plugins
- Focus on missing functionality: fzf-like selection, git utils, custom completions
- Most prompt/theme functionality covered by oh-my-posh
- Syntax highlighting and autosuggestions are built-in
- Custom zsh functions need to be ported to nushell syntax

# Nushell Configuration

Modern shell with structured data, vi mode, and shell integration for Alacritty/Windows Terminal/VS Code.

## Key Features

- **Vi mode** with insert/normal/visual modes and cursor shapes
- **Shell integration** (OSC codes) for clickable links, window titles, VS Code
- **Plugin system** via nupm and NixOS packages
- **Modern UI** with rounded tables, grid icons, fancy errors
- **Tool integration**: Atuin history, Zoxide navigation, Carapace completions

## Quick Reference

### Vi Mode Keybindings

| Insert Mode | Action | Normal Mode | Action |
|-------------|--------|-------------|--------|
| `ESC`, `Ctrl+[` | Normal mode | `i/I/a/A` | Insert modes |
| `Ctrl+A` | Line start | `h/j/k/l` | Navigation |
| `Ctrl+E` | Line end | `w/b/e` | Word motions |
| `Ctrl+K` | Kill to end | `d/c/y` | Operators |
| `Ctrl+U` | Kill to start | `dd/cc/yy` | Line ops |
| `Ctrl+W` | Delete word | `u`, `Ctrl+R` | Undo/redo |
| `Ctrl+R` | History search | `v` | Visual mode |
| `Tab` | Completion | `/` | Search |

### Plugins

| Plugin | Source | Description |
|--------|--------|-------------|
| `clipboard` | nupm | System clipboard copy/paste |
| `formats` | NixOS | EML, ICS, INI, plist, VCF support |
| `query` | NixOS | JSON, XML, web data queries |
| `gstat` | NixOS | Git status as structured data |

Usage: `clipboard copy`, `clipboard paste`, `query web`, `gstat`

## Zsh Migration: Complete ✅

**Verdict:** Feature parity achieved. Nushell ready as primary shell.

**What changed:** Zsh+zim → Nushell+carapace. Carapace bridges (Cobra/Clap) replace custom completions.

| Zsh Feature | Nushell | Notes |
|-------------|---------|-------|
| Vi mode, completions, history | ✅ | Full parity |
| zoxide, fzf, atuin, direnv | ✅ | Native integration |
| container-use, aws-sso, git-branchless | ✅ | Carapace auto-bridge |
| Prompt (gitster) | ✅ | Oh-My-Posh catppuccin_mocha |
| OSC codes (terminal/VS Code) | ✅ | Surpasses zsh |

**Limitations:** jk/jj escape (use ESC), text objects (use `v` for nvim), dot repeat (basic).

**Advantage:** Structured data + better terminal integration.

## Files

- `config.nu.tmpl` - Vi mode, plugins, integrations
- `env.nu.tmpl` - Environment, PATH, Oh-My-Posh
- `modules/` - Custom: bitwarden, claude-helpers, sesh

See [PLUGINS.md](PLUGINS.md) for plugin details.

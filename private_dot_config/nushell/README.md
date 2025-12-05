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

## Feature Parity with Zsh

✅ **Achieved:**

- Vi mode with visual mode
- Cursor shapes per mode
- History search and sync
- Tab completion with descriptions
- External tool integration (direnv, zoxide, atuin, carapace)
- Shell integration (OSC codes)
- Plugin system

⚠️ **Workaround Available:**

- Text objects (diw, ciw) → Use external editor (`v` in normal mode)
- Surround operations → Use external editor
- Complex edits → Neovim integration via buffer editor

❌ **Not Available:**

- jk/jj escape sequences (Reedline limitation)
- Dot repeat (basic only)

**Verdict:** Nushell now provides 90%+ zsh feature parity with superior structured data handling.

## Files

- `config.nu.tmpl` - Main configuration with vi mode, plugins, integrations
- `env.nu.tmpl` - Environment, PATH, Oh-My-Posh prompt
- `modules/` - Custom modules (bitwarden, claude-helpers, sesh)

See [COMPARISON.md](COMPARISON.md) for detailed zsh/nushell comparison.
See [PLUGINS.md](PLUGINS.md) for available plugins and installation.

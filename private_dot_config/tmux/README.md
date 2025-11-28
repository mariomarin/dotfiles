# Tmux Configuration

Custom tmux configuration with vi-mode, session management, seamless navigation, and native clipboard integration.

## Features

- **Vi-mode**: Vim-style keybindings in copy mode
- **Session Management**: Enhanced with sesh for quick session switching
- **Seamless Navigation**: Unified navigation between tmux panes and Neovim splits
- **Native Clipboard**: Automatic integration with system clipboard (X11/Wayland)
- **True Color Support**: 24-bit color support for better themes
- **Plugin Manager**: TPM (Tmux Plugin Manager) for declarative plugin management

## Requirements

### Clipboard Support

Native clipboard integration requires:

- **X11**: `xclip` package
- **Wayland**: `wl-clipboard` package (provides `wl-copy`)

The configuration automatically detects your display server (X11/Wayland) and uses the appropriate clipboard tool.

## Keybindings

For a complete list of keybindings, see **[KEYBINDINGS.md](KEYBINDINGS.md)**.

**Quick reference**:

- **Prefix key**: `C-a` (Ctrl+a)
- **Session picker**: `prefix T` (sesh with preview)
- **Pane navigation**: `M-h/j/k/l` (works in both tmux and Neovim)
- **Copy mode**: `prefix /` to enter and search

## Plugin List

- **tmux-sensible**: Sensible tmux defaults
- **tmux-yank**: System clipboard integration
- **tmux-resurrect**: Session persistence across reboots
- **tmux-continuum**: Automatic session saves
- **tmux-fingers**: Copy text with hints (like Vimium)
- **tmux-tilish**: i3wm-like navigation and layouts
- **tmux-harpoon**: Quick navigation between saved sessions and panes
- **tmux-fuzzback**: Search scrollback with FZF
- **extrakto**: Extract and insert text from panes

## Neovim Integration

Using **aserowy/tmux.nvim** for seamless tmux/neovim integration:

- **Navigation**: `M-h/j/k/l` to move between tmux panes and Neovim splits
  - Provided by tmux-tilish with built-in vim awareness
  - Works seamlessly in both tmux and Neovim
- **Resizing**: Omarchy-style keybindings for pane resizing
  - Configured in both tmux (tmux-tilish) and Neovim (tmux.nvim)
  - Vim-aware resizing that works in both environments
- **Clipboard Sync**: Automatic synchronization of registers between Neovim instances and tmux
- **Cycle Navigation**: Wraps around to opposite pane when at edge

## Settings

- **Mouse support**: Enabled
- **Base index**: Starts at 1 (both windows and panes)
- **Vi-mode**: Enabled for copy mode
- **True color**: 24-bit color support
- **Status bar theme**: minimal-tmux-status

## Configuration Files

- `tmux.conf` - Main configuration entry point
- `settings.tmux` - General tmux settings
- `plugins.tmux` - Plugin declarations and configurations
- `mappings/root.tmux` - Root key table mappings (no prefix)
- `mappings/prefix.tmux` - Prefix key mappings
- `mappings/copy-mode-vi.tmux` - Vi copy mode bindings

## Related Documentation

- [KEYBINDINGS.md](KEYBINDINGS.md) - Complete keybinding reference
- [CLAUDE.md](CLAUDE.md) - AI guidance for tmux configuration

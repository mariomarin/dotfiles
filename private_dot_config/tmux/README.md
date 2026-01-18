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

| Plugin              | Description                         |
| ------------------- | ----------------------------------- |
| tmux-sensible       | Sensible defaults                   |
| tmux-yank           | System clipboard integration        |
| tmux-resurrect      | Session persistence                 |
| tmux-continuum      | Auto-save + auto-start              |
| tmux-thumbs         | Copy text with hints (like Vimium)  |
| tmux-tilish         | i3wm-style navigation and layouts   |
| tmux-harpoon        | Quick jump to saved sessions/panes  |
| tmux-fuzzback       | Search scrollback with fzf          |
| minimal-tmux-status | Clean status bar theme              |

## Session Persistence & Auto-Start

Two plugins work together to persist sessions across reboots:

| Plugin             | Role                                                    |
| ------------------ | ------------------------------------------------------- |
| **tmux-resurrect** | Saves/restores session state (windows, panes, layouts)  |
| **tmux-continuum** | Auto-saves periodically + auto-starts tmux at login     |

### How It Works

1. **Login**: continuum's LaunchAgent (macOS) or systemd service (Linux) starts tmux
2. **Auto-restore**: `@continuum-restore 'on'` triggers resurrect to restore last saved state
3. **Auto-save**: continuum saves session state every 15 minutes (default)

### Platform-Specific Auto-Start

| Platform        | Method                                  | Config                                |
| --------------- | --------------------------------------- | ------------------------------------- |
| macOS           | LaunchAgent (`~/Library/LaunchAgents`)  | `@continuum-boot-options 'alacritty'` |
| Linux (systemd) | User service (`~/.config/systemd/user`) | `@continuum-systemd-start-cmd`        |

### Manual Save/Restore

| Keybinding     | Action                |
| -------------- | --------------------- |
| `prefix C-s`   | Save session state    |
| `prefix C-r`   | Restore session state |

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

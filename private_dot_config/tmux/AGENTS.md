# AGENTS.md - Tmux Configuration

This file provides guidance to AI agents and assistants when working with the tmux configuration.

## Directory Structure

```
private_dot_config/tmux/
├── tmux.conf           # Main tmux configuration
├── settings.tmux       # General tmux settings
├── plugins.tmux        # Plugin configurations
└── mappings/           # Key binding configurations
    ├── root.tmux       # Root key table mappings
    ├── prefix.tmux     # Prefix key mappings
    └── copy-mode-vi.tmux # Vi copy mode bindings
```

## Plugin Management

Tmux plugins are managed declaratively through chezmoi's external dependency system:
- Defined in `private_dot_local/share/tmux/plugins/.chezmoiexternal.toml`
- Automatically downloaded/updated with `chezmoi apply`
- No manual TPM commands needed

### Installed Plugins
- **tpm**: Tmux Plugin Manager (base)
- **tmux-sensible**: Sensible defaults
- **tmux-yank**: System clipboard integration
- **tmux-resurrect**: Session persistence
- **tmux-continuum**: Automatic session saves
- **vim-tmux-navigator**: Seamless vim/tmux navigation
- **catppuccin/tmux**: Catppuccin theme

## Configuration Components

### Main Configuration (`tmux.conf`)
Entry point that sources all other configuration files:
1. Settings (general options)
2. Plugins (TPM and plugin list)
3. Key mappings (organized by table)

### Settings (`settings.tmux`)
- **Terminal**: True color support, 256 colors
- **Mouse**: Full mouse support enabled
- **Windows/Panes**: Base index 1, automatic renumbering
- **Status Bar**: Position, update interval, theme
- **History**: 10,000 lines scroll buffer
- **Display**: Pane/message display times

### Key Mappings

#### Prefix Key
- Default: `Ctrl-b`
- All command mode bindings require prefix

#### Root Bindings (`mappings/root.tmux`)
Direct key bindings without prefix:
- `C-h/j/k/l`: Navigate between panes (vim-tmux-navigator)
- Window switching shortcuts

#### Prefix Bindings (`mappings/prefix.tmux`)
After pressing prefix key:
- `|`: Split window horizontally
- `-`: Split window vertically
- `r`: Reload configuration
- `h/j/k/l`: Resize panes
- `H/J/K/L`: Navigate panes

#### Copy Mode (`mappings/copy-mode-vi.tmux`)
Vi-style bindings in copy mode:
- `v`: Begin selection
- `y`: Copy selection
- `C-v`: Rectangle selection
- `/`: Search forward
- `?`: Search backward

## Session Management

### Resurrect/Continuum
- Automatic session saves every 15 minutes
- Restore with `prefix + Ctrl-r`
- Save with `prefix + Ctrl-s`
- Persists pane contents, programs, working directories

### Session Files
Stored in `~/.local/share/tmux/resurrect/`

## Theme Configuration

Using Catppuccin theme (mocha flavor):
- Matches Neovim and terminal colorscheme
- Configurable through plugin options
- Status bar modules customizable

## Common Tasks

### Creating Custom Bindings
1. Add to appropriate mapping file
2. Use `bind-key` for prefix bindings
3. Use `bind-key -n` for root bindings
4. Reload with `prefix + r`

### Adding Plugins
1. Edit `.chezmoiexternal.toml` in plugins directory
2. Add plugin repository details
3. Run `chezmoi apply`
4. Add to `plugins.tmux` if needed

### Customizing Status Bar
1. Edit catppuccin theme options in `plugins.tmux`
2. Or override in `settings.tmux`
3. Reload configuration

### Window/Pane Management
```bash
# Windows
prefix + c     # Create new window
prefix + n/p   # Next/previous window
prefix + 0-9   # Switch to window number
prefix + ,     # Rename window
prefix + &     # Kill window

# Panes
prefix + |     # Split horizontally
prefix + -     # Split vertically
prefix + x     # Kill pane
prefix + z     # Zoom/unzoom pane
prefix + !     # Convert pane to window
prefix + space # Cycle pane layouts
```

## Integration with Other Tools

### Neovim
- Seamless navigation with vim-tmux-navigator
- Shared clipboard through tmux-yank
- Consistent colorscheme (Catppuccin)

### Shell
- Automatic window renaming based on running command
- Shell integration for better titles
- Directory tracking for new panes

### System Clipboard
- Copy to system clipboard with `y` in copy mode
- Paste from system clipboard with normal paste
- Works with both X11 and Wayland

## Performance Tips

- Use `set -g escape-time 0` for instant command sequences
- Limit status bar refresh rate if experiencing lag
- Disable automatic-rename for better performance
- Use native terminal scrolling when possible

## Troubleshooting

### Common Issues
1. **Plugins not loading**: Run `chezmoi apply` to fetch
2. **Colors incorrect**: Ensure `TERM=tmux-256color`
3. **Clipboard not working**: Check `tmux-yank` dependencies
4. **Navigation conflicts**: Verify vim-tmux-navigator setup

### Debug Commands
```bash
# Show current settings
tmux show-options -g

# List key bindings
tmux list-keys

# Check plugin status
tmux run-shell ~/.local/share/tmux/plugins/tpm/scripts/check_tmux_version.sh

# Reload configuration
tmux source-file ~/.config/tmux/tmux.conf
```

## Important Notes

- Configuration assumes tmux 3.0+ for full feature support
- Plugins managed by chezmoi, not manual TPM commands
- Keep mappings consistent with Neovim for muscle memory
- Test configuration changes in new sessions first
- Use session management for persistent workflows

## Related Documentation

- [Root AGENTS.md](../../AGENTS.md)
- [Neovim AGENTS.md](../nvim/AGENTS.md)
- [Tmux Manual](https://man.openbsd.org/tmux)
- [TPM Documentation](https://github.com/tmux-plugins/tpm)
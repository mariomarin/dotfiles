# CLAUDE.md - Tmux Configuration

This file provides guidance to Claude Code when working with the tmux configuration.

## ⚠️ IMPORTANT: Always Update Documentation

**When making ANY changes to tmux keybindings or settings:**
1. **ALWAYS** update the [README.md](./README.md) keybindings documentation
2. **ALWAYS** check for duplicate or conflicting keybindings
3. **ALWAYS** document plugin-specific keybindings
4. **NEVER** leave undocumented keybindings

## Directory Structure

```
private_dot_config/tmux/
├── CLAUDE.md           # This file - AI guidance
├── README.md           # User-facing keybindings documentation
├── tmux.conf           # Main tmux configuration
├── settings.tmux       # General tmux settings
├── plugins.tmux        # Plugin configurations
└── mappings/           # Key binding configurations
    ├── root.tmux       # Root key table mappings
    ├── prefix.tmux     # Prefix key mappings
    └── copy-mode-vi.tmux # Vi copy mode bindings
```

## Key Configuration Files

### tmux.conf
- Entry point that sources all other configuration files
- Order matters: settings → mappings → plugins → TPM initialization

### settings.tmux
- Prefix key: `C-a`
- Terminal settings (colors, mouse, etc.)
- Basic options

### plugins.tmux
- Plugin declarations and settings
- Custom keybindings for plugins
- Plugin-specific configuration

### mappings/
- **root.tmux**: Direct keybindings without prefix
- **prefix.tmux**: Bindings requiring prefix key
- **copy-mode-vi.tmux**: Vi-style copy mode bindings

## Plugin Management

Plugins are managed declaratively through chezmoi:
- Defined in `private_dot_local/share/tmux/plugins/.chezmoiexternal.toml`
- Automatically downloaded/updated with `chezmoi apply`
- No manual TPM commands needed

## Neovim Integration

Currently using **aserowy/tmux.nvim** for seamless integration:
- Navigation: `C-h/j/k/l` between tmux panes and Neovim splits
- Resizing: `M-H/J/K/L` to resize panes (in Neovim)
- Clipboard sync between Neovim instances
- Configured in Neovim's `lua/plugins/tmux-navigation.lua`

## Common Tasks

### Adding a New Keybinding
1. Add binding to appropriate file in `mappings/`
2. **UPDATE README.md** with the new keybinding
3. Check for conflicts with existing bindings
4. Test the binding

### Adding a New Plugin
1. Add to `.chezmoiexternal.toml` in plugins directory
2. Add configuration to `plugins.tmux`
3. **UPDATE README.md** with plugin keybindings
4. Run `chezmoi apply` to fetch plugin

### Changing Existing Bindings
1. Make the change in the appropriate file
2. **UPDATE README.md** immediately
3. Check for conflicts or duplicates
4. Update conflict section if needed

## Documentation Standards

The README.md must include:
1. **Complete keybinding list** organized by category
2. **Plugin-specific keybindings** for each plugin
3. **Conflict warnings** with ⚠️ symbols
4. **Default bindings** that plugins provide
5. **Clear descriptions** for each binding

## Testing Checklist

Before committing tmux changes:
- [ ] All keybindings documented in README.md
- [ ] No undocumented plugin bindings
- [ ] Conflicts clearly marked
- [ ] Tested all modified bindings
- [ ] Checked for duplicates

## Common Keybinding Conflicts

Watch out for these common conflicts:
- `prefix ?` - Often used by search and help features
- `prefix F` - Common for "find" features
- `M-h/j/k/l` - Navigation keys used by multiple plugins
- `prefix b` - Buffer operations vs status bar toggle

## Important Notes

- Always preserve user preferences when resolving conflicts
- Document WHY a conflict was resolved in a particular way
- Keep the README.md as the single source of truth for keybindings
- Test integration with Neovim after navigation changes
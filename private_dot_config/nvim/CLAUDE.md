# CLAUDE.md - Neovim Configuration

This file provides guidance to AI agents and assistants when working with the Neovim configuration.

## Directory Structure

```text
private_dot_config/nvim/
├── init.lua                  # Entry point for Neovim configuration
├── lua/
│   ├── config/              # Core configuration
│   │   ├── keymaps.lua     # Custom keymaps
│   │   ├── lazy.lua        # Lazy.nvim setup and bootstrap
│   │   └── options.lua     # Neovim options
│   └── plugins/            # Plugin configurations
│       ├── chezmoi.lua     # Chezmoi integration
│       ├── colorscheme.lua # Catppuccin theme
│       ├── dap.lua         # Debug adapter protocol setup
│       ├── disable.lua     # Disabled plugins
│       ├── editor.lua      # Editor enhancements (nvim-tree)
│       ├── mason.lua       # LSP/DAP package management
│       ├── navigation.lua  # Navigation plugins (leap, tmux)
│       └── toggle-fixes.lua # Toggle keymap fixes
├── stylua.toml             # Lua formatter configuration
└── dot_neoconf.json        # Project-specific Neovim settings
```

## Configuration Framework

- **Base Distribution**: LazyVim
- **Plugin Manager**: lazy.nvim
- **LSP Management**: Mason (with NixOS compatibility)
- **Color Scheme**: Catppuccin (mocha flavor)
- **File Explorer**: nvim-tree (neo-tree disabled)

## Language Support

The configuration includes LazyVim extras for:

- Go (`lang.go`)
- TypeScript (`lang.typescript`)
- Python (`lang.python`)
- Rust (`lang.rust`)
- YAML (`lang.yaml`)
- Docker (`lang.docker`)
- Markdown (`lang.markdown`)
- Nix (`lang.nix`)
- Telescope (`editor.telescope`)
- Harpoon2 (`editor.harpoon2`)
- Chezmoi (`util.chezmoi`)
- Test support (`test.core`)
- DAP Core (`dap.core`)
- DAP Lua (`dap.nlua`)

## NixOS Compatibility

Special handling for NixOS systems:

- Mason prefers system-installed tools over downloading binaries
- Python debugging uses system debugpy instead of Mason-installed version
- Automatic LSP installation is disabled
- See `lua/plugins/mason.lua` and `lua/plugins/dap.lua` for implementation

## Key Customizations

### Navigation

- **Leap.nvim**: Quick cursor movement with `s` and `S`
- **Tmux Navigator**: Seamless navigation between Neovim and tmux panes
- **Session Management**: persistence.nvim (LazyVim default)
  - `<leader>qs` - Save current session
  - `<leader>ql` - Load/restore last session
  - `<leader>qd` - Don't save session on exit
- **Harpoon2**: Quick file navigation
  - `<leader>H` - Add current file to Harpoon list
  - `<leader>h` - Toggle Harpoon quick menu
  - `<leader>1-9` - Jump to specific Harpoon marks

### Editor Enhancements

- **File Explorer**: nvim-tree with git integration
- **Chezmoi Integration**: Automatic source directory detection
- **Toggle Keymaps**: Fixed Snacks.nvim toggle mappings

## Code Style

- **Formatter**: stylua for Lua files
- **Configuration**: Follow LazyVim conventions
- **Plugin Structure**: One plugin per file in `lua/plugins/`

## Common Tasks

### Adding a New Plugin

1. Create a new file in `lua/plugins/`
2. Return a table with the plugin specification
3. Follow LazyVim's plugin specification format

### Modifying Keymaps

1. Edit `lua/config/keymaps.lua` for global keymaps
2. Add plugin-specific keymaps in the plugin's configuration file

### Debugging Issues

1. Check `:checkhealth` for system compatibility
2. Review `:Lazy` for plugin status
3. Verify Mason installations with `:Mason`

## Important Notes

- Always format Lua files with stylua before committing
- Test changes on both NixOS and standard Linux systems
- Maintain compatibility with LazyVim's default configuration
- Document any deviations from LazyVim defaults

## Related Documentation

- [KEYBINDINGS.md](KEYBINDINGS.md) - Complete keybinding reference
- [Root CLAUDE.md](../../CLAUDE.md) - Repository overview
- [LazyVim Documentation](https://www.lazyvim.org/)
- [Neovim Documentation](https://neovim.io/doc/)

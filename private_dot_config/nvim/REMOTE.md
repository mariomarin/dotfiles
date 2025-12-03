# Neovim Remote Setup

## SSH + Neovim

```bash
ssh user@remote
nvim file.txt
```

Clipboard works automatically via system clipboard provider.

## VS Code Remote SSH

Install extension: "Remote - SSH"

```bash
# Connect
Ctrl+Shift+P → "Remote-SSH: Connect to Host"
# Enter: user@hostname

# Works like local VS Code
- Full LSP support
- Terminal access
- Git integration
```

## Tmux Integration

### Navigation

Seamless movement between nvim splits and tmux panes:

- `M-h/j/k/l` - Unified navigation
- Configured via tmux.nvim plugin

See [tmux-navigation.lua](lua/plugins/tmux-navigation.lua)

### Clipboard Sync

The tmux.nvim plugin syncs clipboard:

- Copy in nvim → Available in tmux
- Copy in tmux → Available in nvim
- Respects system clipboard settings

## LazyVim Sessions

Sessions save/restore automatically:

- `<leader>qs` - Save session
- `<leader>ql` - Load last session

Works across SSH disconnects.

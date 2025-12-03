# Neovim Remote

## Tmux Integration

### Navigation

`M-h/j/k/l` works across nvim splits AND tmux panes

Configured in: [tmux-navigation.lua](lua/plugins/tmux-navigation.lua)

### Clipboard Sync

tmux.nvim syncs clipboard between nvim and tmux

## Sessions

- `<leader>qs` - Save session
- `<leader>ql` - Load last session

Persists across SSH disconnects

# Neovim Remote

## Tmux Integration

### Navigation

`M-h/j/k/l` works across nvim splits AND tmux panes

Configured in: [tmux-navigation.lua](lua/plugins/tmux-navigation.lua)

### Clipboard Sync

| Context | Method                        | Config              |
|---------|-------------------------------|---------------------|
| Local   | tmux.nvim (tmux buffers)      | tmux-navigation.lua |
| SSH     | OSC 52 (terminal passthrough) | options.lua         |

Over SSH, yanks go to your **local** clipboard via OSC 52.

**Requirements:**

- Terminal with OSC 52 support (Alacritty, iTerm2, WezTerm, Kitty)
- tmux `set-clipboard on` and `allow-passthrough on`

## Sessions

- `<leader>qs` - Save session
- `<leader>ql` - Load last session

Persists across SSH disconnects

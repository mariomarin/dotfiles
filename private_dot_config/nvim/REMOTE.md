# Neovim Remote

## Tmux Integration

### Navigation

`M-h/j/k/l` works across nvim splits AND tmux panes

Configured in: [tmux-navigation.lua](lua/plugins/tmux-navigation.lua)

### Clipboard Sync

| Context | Method                        | Config              | Size Limit |
|---------|-------------------------------|---------------------|------------|
| Local   | tmux.nvim (tmux buffers)      | tmux-navigation.lua | Unlimited  |
| SSH     | OSC 52 (terminal passthrough) | options.lua         | ~100KB     |
| SSH     | Clipper (reverse tunnel)      | clipper.lua         | Unlimited  |

#### OSC 52 (Automatic, < 100KB)

Over SSH, yanks automatically go to your **local** clipboard via OSC 52.

**Requirements:**
- Terminal with OSC 52 support (Alacritty, iTerm2, WezTerm, Kitty)
- tmux `set-clipboard on` and `allow-passthrough on`

#### Clipper (Manual, Unlimited Size)

For large buffers over SSH, use Clipper with `<leader>y`:

**Requirements:**
- Clipper daemon running on local machine (port 8377)
- SSH RemoteForward configured for remote host
- `nc` (netcat) command available on remote

**Usage:**
```vim
" Send last yank to Clipper
<leader>y

" Or use command
:Clip
:Clipper  " alias
```

**Automatic Mode:** vim-clipper sends all yanks to Clipper via `TextYankPost` autocommand (disable with `let g:ClipperAuto=0`).

## Sessions

- `<leader>qs` - Save session
- `<leader>ql` - Load last session

Persists across SSH disconnects

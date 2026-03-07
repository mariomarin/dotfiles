# Clipper Zsh Module - AI Assistant Context

## Purpose

This Zsh module provides clipboard integration via Clipper, enabling seamless clipboard access both locally and over SSH connections.

## Architecture

### Core Components

1. **`clip` function**: Main entry point for copying to clipboard
   - Auto-detects `nc` flag requirements (-N for Ubuntu/Debian)
   - Connects to Clipper daemon on localhost:8377
   - Provides error messages if connection fails

2. **`clipfile` function**: Convenience wrapper for file copying
   - Validates file exists before attempting copy
   - Provides user feedback on success

3. **`clipped` function**: Command wrapper with tee
   - Executes command
   - Displays output to terminal
   - Copies output to clipboard simultaneously

### Design Decisions

1. **nc flag detection**: Uses silent connection test to detect if `-N` flag is needed
   - Avoids hardcoding platform-specific behavior
   - Handles both GNU and BSD netcat variants

2. **Error handling**: Clear error messages guide users to troubleshooting
   - Suggests checking if Clipper is running
   - Provides command to verify (lsof)

3. **Environment variables**: Allow customization without code changes
   - CLIPPER_HOST: Override default localhost
   - CLIPPER_PORT: Override default 8377 port

## Integration Points

### With Clipper Daemon

- Connects via TCP to localhost:8377
- Expects Clipper to be running as:
  - macOS: LaunchAgent (~/Library/LaunchAgents/org.local.clipper.plist)
  - Linux: systemd user service (~/.config/systemd/user/clipper.service)
  - NixOS: Managed by nix-darwin or NixOS configuration

### With SSH

- Requires RemoteForward configuration in ~/.ssh/config
- Example: `RemoteForward 8377 localhost:8377`
- Creates tunnel from remote machine back to local Clipper daemon

### With Other Tools

- **tmux**: Can be used in copy-mode bindings
- **vim/neovim**: Integrates via vim-clipper plugin
- **shell scripts**: Any command output can be piped to `clip`

## Common Tasks

### Adding to tmux

```bash
# In ~/.config/tmux/mappings/copy-mode-vi.tmux
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "clip"
```

### Adding to vim

```vim
" In ~/.config/nvim/init.vim or init.lua
nnoremap <leader>y :call system('clip', @0)<CR>
```

### Troubleshooting Connection Issues

1. Check if Clipper is running:
   ```bash
   lsof -i :8377
   ```

2. Check service status:
   ```bash
   # macOS
   launchctl list | grep clipper

   # Linux
   systemctl --user status clipper
   ```

3. Check SSH tunnel (remote):
   ```bash
   # Should show forwarded port
   ss -tulpn | grep 8377
   ```

## Security Considerations

- Clipper listens only on 127.0.0.1 (localhost)
- No authentication required (relies on localhost access control)
- SSH RemoteForward creates encrypted tunnel
- File system permissions prevent unauthorized access to UNIX sockets (if used)

## Performance

- Minimal overhead: Simple TCP connection to local daemon
- No size limits: Can handle large buffers (unlike OSC 52's ~100KB limit)
- Asynchronous: Does not block shell when used with process substitution
- nc detection: Flag detection happens once at module load time for optimal performance

## Future Enhancements

Potential additions:
- UNIX domain socket support (more secure than TCP)
- Clipboard paste function (retrieve from clipboard)
- Integration with `wl-clipboard` or `xclip` as fallback
- Automatic Clipper daemon health check on module load

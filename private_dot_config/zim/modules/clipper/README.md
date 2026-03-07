# Clipper Zsh Module

Provides Zsh functions for clipboard integration via [Clipper](https://github.com/wincent/clipper).

## Features

- **Cross-platform clipboard**: Works locally and over SSH via RemoteForward
- **No size limits**: Unlike OSC 52 (~100KB max), Clipper handles large buffers
- **Smart nc detection**: Automatically detects if `nc` requires `-N` flag at module load time
- **Helper functions**: File copying, command output copying with tee
- **Safe execution**: Uses direct command execution instead of eval

## Requirements

- Clipper daemon running on local machine (port 8377)
- `nc` (netcat) command available
- SSH RemoteForward configured for remote usage

## Functions

### `clip`

Copy stdin to clipboard via Clipper.

```bash
echo "Hello World" | clip
cat large-file.txt | clip
kubectl logs pod-name | clip
```

### `clipfile <filename>`

Copy file contents to clipboard.

```bash
clipfile ~/.ssh/config
clipfile /var/log/syslog
```

### `clipped <command>`

Execute command, display output, and copy to clipboard.

```bash
clipped ls -la
clipped git log --oneline -10
```

## Aliases

- `pclip` - Alias for `clip` (matches `pbcopy` naming convention)

## Configuration

Environment variables (optional):

```bash
export CLIPPER_HOST=localhost  # Clipper server address
export CLIPPER_PORT=8377       # Clipper server port
```

## Setup

### Local Machine (macOS)

Clipper should be running via LaunchAgent:

```bash
# Check status
launchctl list | grep clipper
lsof -i :8377

# View logs
tail -f ~/Library/Logs/clipper.log
```

### Remote Machine (SSH)

Add to `~/.ssh/config`:

```ssh
Host myremotehost
  RemoteForward 8377 localhost:8377
```

## Integration

This module integrates with:

- **tmux**: Use `clip` in tmux bindings for copy-mode
- **vim/neovim**: Use `vim-clipper` plugin for automatic integration
- **shell scripts**: Pipe any output to `clip`

## Examples

```bash
# Copy directory tree
tree | clip

# Copy git diff
git diff HEAD~1 | clip

# Copy with command output visible
ls -la | tee >(clip)

# Copy file
clipfile README.md

# Execute and copy
clipped kubectl get pods -A
```

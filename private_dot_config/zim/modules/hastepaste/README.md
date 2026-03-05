# hastepaste

Hastebin-compatible paste functions for sharing command output and text snippets.

## Description

This module provides utilities for pasting content to a Hastebin-compatible server.
It requires the `HASTE_SERVER` environment variable to be set with your server domain.

## Configuration

Set the `HASTE_SERVER` environment variable in your `.env.work` file:

```bash
# Simple domain (https:// assumed)
export HASTE_SERVER="paste.example.com"

# Or full URL (compatible with haste gem)
export HASTE_SERVER="https://paste.example.com/"
```

Both formats are supported for compatibility with the `haste` Ruby gem.

## Functions

### `hastepaste [extension]`

Paste content from stdin to the Haste server.

**Arguments:**
- `extension` (optional): File extension for syntax highlighting (e.g., "py", "js", "md")

**Example:**
```zsh
echo "test content" | hastepaste
cat script.py | hastepaste py
```

### `capture_command <command>`

Execute a command, display output to terminal, and automatically paste it to the Haste server with ANSI escape codes removed.

**Arguments:**
- `command`: The command to execute (as a string)

**Example:**
```zsh
capture_command 'terragrunt plan'
capture_command 'kubectl get pods'
```

### `pipe_haste`

Pipe command output to both the terminal and the Haste server with ANSI escape codes removed.

**Example:**
```zsh
terragrunt plan | pipe_haste
kubectl describe pod my-pod | pipe_haste
```

## Requirements

- `curl`: For HTTP requests
- `HASTE_SERVER` environment variable set

## Notes

- All functions automatically strip ANSI escape codes before pasting
- The paste URL is output to the terminal
- The `| cat` at the end of functions ensures URL appears before shell prompt

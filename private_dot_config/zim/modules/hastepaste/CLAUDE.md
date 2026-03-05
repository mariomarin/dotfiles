# CLAUDE.md - Hastepaste Module

This Zim module provides Hastebin-compatible paste functions for sharing command output and code snippets.

## Structure

```text
hastepaste/
├── init.zsh           # Module initialization with functions
├── README.md          # User documentation
└── CLAUDE.md          # This file
```

## Design Philosophy

This module provides a clean, zsh-idiomatic interface for pasting content to Hastebin-compatible servers:

1. **Environment-driven configuration** - Uses `HASTE_SERVER` from `.env.work`
2. **Multiple paste methods** - Direct paste, command capture, or pipe
3. **ANSI stripping** - Automatically removes terminal escape codes
4. **Idiomatic zsh** - Uses zsh builtins and parameter expansion

## Key Features

### Environment Configuration

- Requires `HASTE_SERVER` environment variable
- Graceful degradation if not configured (warning, no error)
- Domain kept in `.env.work` (not tracked in git)

### Three Usage Patterns

1. **Direct paste**: `echo "content" | hastepaste [ext]`
2. **Command capture**: `capture_command 'command'` - executes and pastes
3. **Pipe capture**: `command | pipe_haste` - pipes through to terminal and paste

### Idiomatic Zsh Implementation

- Uses `print -u 2 -P` for colored stderr output
- Parameter expansion for JSON parsing (no awk dependency for simple extraction)
- `${PWD}` instead of `$(pwd)`
- `(( $# != 1 ))` instead of `[[ $# -ne 1 ]]`
- `${extension:+.$extension}` for optional extension handling
- `-E` flag for portable sed (works on both GNU and BSD)

## Configuration

Add to `.env.work`:

```bash
# Simple domain (https:// assumed)
export HASTE_SERVER="paste.example.com"

# Or full URL (compatible with haste Ruby gem)
export HASTE_SERVER="https://paste.example.com/"
```

Both formats supported for compatibility with existing `haste` gem installations.

## Dependencies

- `curl` (checked at module load)
- `sed` (for ANSI code stripping)
- `tee` (for dual output)

## Related Modules

This module is inspired by Pinterest's internal EKS Runbook practices for sharing command output during troubleshooting.

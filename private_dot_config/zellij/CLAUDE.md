# CLAUDE.md - Zellij Configuration

## Overview

Zellij configured with tmux-like `Ctrl+a` prefix bindings. Default mode is **locked** (passthrough).

## Configuration

- `config.kdl.tmpl` - Main config (template for OS-specific clipboard command)
- `KEYBINDINGS.md` - Complete keybindings reference

## Key Design Decisions

1. **Locked by default**: All keys pass through to applications. `Ctrl+a` enters tmux mode.
2. **Tmux muscle memory**: Keybindings mirror tmux where possible.
3. **Alt bindings**: Quick actions without prefix (like tmux-tilish).
4. **Template for clipboard**: Uses `pbcopy` on macOS, OSC52 on Linux.

## Feature Gaps vs Tmux

| Missing | Workaround |
| ------- | ---------- |
| tmux-fingers (hints) | Mouse + copy_on_select, or edit scrollback |
| extrakto (fuzzy extract) | Search mode or edit scrollback |
| tmux-harpoon | Session manager |
| fuzzback | Search mode (`/`) |

## Common Tasks

### Adding Keybindings

Edit `config.kdl.tmpl`, update `KEYBINDINGS.md`.

### Testing Config

```bash
zellij setup --check
```

## Session Persistence

Built-in via `session_serialization true`. No plugins needed.

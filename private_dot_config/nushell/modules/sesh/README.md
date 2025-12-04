# Sesh Module

Smart tmux session manager with fuzzy selection for Nushell.

## Installation

```nu
nupm install --path ~/.config/nushell/modules/sesh
```

## Usage

```nu
use sesh *
```

## Available Commands

### `sesh sessions` - Interactive Session Selector

Select and connect to a tmux session interactively:

```nu
sesh sessions
```

Features:

- Lists all available tmux sessions and zoxide directories
- Fuzzy search with fzf or skim
- Automatically connects to selected session
- Creates new session if directory selected

## Aliases

- `ss` → `sesh sessions` (quick shortcut)

## Requirements

- `sesh` - Session manager binary
- `fzf` - Fuzzy finder (recommended)
- `nu_plugin_skim` - Optional Nushell fuzzy selection plugin (alternative to fzf)
- `tmux` - Terminal multiplexer

## Fuzzy Finder Support

The module automatically detects and uses the best available fuzzy finder:

1. **nu_plugin_skim** - If registered, provides native Nushell integration
2. **fzf** - External fuzzy finder (fallback)

To install nu_plugin_skim:

```bash
cargo install nu_plugin_skim
nu -c "plugin add ~/.cargo/bin/nu_plugin_skim"
```

## Integration with Tmux

Add this to your tmux.conf for quick access:

```tmux
# Open sesh session selector
bind-key "s" run-shell "sesh connect \"$(
  sesh list -t -c | fzf \
    --height 40% \
    --reverse \
    --border-label ' sesh ' \
    --border \
    --prompt '⚡  '
)\""
```

## License

MIT

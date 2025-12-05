# Sesh Module

Tmux session manager integration for Nushell.

## Usage

```nu
use sesh *
sesh sessions  # or: ss
```

Lists tmux sessions and zoxide directories with fuzzy search. Connects to selected session or creates new one.

## Requirements

- `sesh` - Session manager binary (in NixOS minimal.nix)
- `fzf` - Fuzzy finder
- `tmux` - Terminal multiplexer

## Installation

Auto-installed via nupm when running `chezmoi apply`.

## Tmux Integration

See `~/.config/tmux/tmux.conf` for keybinding configuration.

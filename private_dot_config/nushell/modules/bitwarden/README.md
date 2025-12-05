# Bitwarden Module

Bitwarden CLI utilities for Nushell.

## Usage

```nu
use bitwarden
```

## Commands

| Command | Description |
|---------|-------------|
| `bitwarden unlock` | Unlock vault, save session to `.env.local` |
| `bitwarden reload` | Reload direnv environment (Unix) |
| `bitwarden get item` | Retrieve complete item |
| `bitwarden get field` | Get specific field from item |
| `bitwarden status` | Check vault status |

## Installation

Auto-installed via nupm when running `chezmoi apply`.

## Integration

Works with justfile targets: `just bw-unlock`, `just bw-reload`

## Requirements

- Bitwarden CLI (`bw`)
- `direnv` (optional, for environment reload)

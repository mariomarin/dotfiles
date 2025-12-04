# Bitwarden Module

Bitwarden CLI utilities for Nushell with proper typing and error handling.

## Installation

```nu
nupm install --path ~/.config/nushell/modules/bitwarden
```

## Usage

```nu
use bitwarden
```

## Available Commands

### `bitwarden unlock` - Unlock Vault

Unlock Bitwarden vault and save session token to `.env.local`:

```nu
bitwarden unlock
```

Features:

- Detects existing valid sessions
- Prompts for master password only when needed
- Saves `BW_SESSION` to `.env.local` for reuse
- Compatible with direnv and justfile workflows

### `bitwarden reload` - Reload Environment

Reload direnv environment to load `BW_SESSION` (Unix only):

```nu
bitwarden reload
```

Features:

- Unix/Linux/macOS only (Windows auto-loads via justfile)
- Validates session after reload
- Shows session status

### `bitwarden get item` - Retrieve Item

Get a complete item from Bitwarden:

```nu
bitwarden get item "dash.cloudflare.com"
```

Returns full item as record with all fields.

### `bitwarden get field` - Get Specific Field

Get a specific field from an item (checks custom fields first):

```nu
bitwarden get field "dash.cloudflare.com" "tunnel_id"
bitwarden get field "ssh-keys" "main"
```

### `bitwarden status` - Check Status

Check current Bitwarden CLI status:

```nu
bitwarden status
```

Returns status record with vault state.

### `bitwarden help` - Show Help

Display help information:

```nu
bitwarden help
```

## Integration with Justfile

This module is designed to work with justfile workflows:

```just
# Unlock Bitwarden
bw-unlock:
    nu -c "use bitwarden; bitwarden unlock"

# Reload environment
bw-reload:
    nu -c "use bitwarden; bitwarden reload"
```

## Requirements

- `bw` (Bitwarden CLI) must be installed and authenticated
- `direnv` (optional, for Unix environment reload)
- Nushell 0.90.0 or later

## Error Handling

All functions use proper error handling with typed returns:

- Missing `BW_SESSION` → Clear error message
- Invalid session → Prompts for re-authentication
- Item not found → Descriptive error
- Field not found → Descriptive error with item name

## Type Safety

Unlike the standalone script, this module:

- ✅ Uses typed command calls (e.g., `sys host` not `sys | get host`)
- ✅ Proper error propagation with `try/catch`
- ✅ Validated record access patterns
- ✅ No silent failures

## License

MIT

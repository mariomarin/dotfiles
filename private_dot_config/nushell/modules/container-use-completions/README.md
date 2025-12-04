# Container Use Completions

Nushell completions for the container-use CLI tool.

## Installation

```nu
nupm install --path ~/.config/nushell/modules/container-use-completions
```

## Usage

```nu
use container-use-completions *
```

Completions will automatically be available for both `container-use` and `cu` commands.

## Supported Commands

### Environment Management

- `container-use list` - List all environments
- `container-use delete [environment-id]` - Delete an environment
- `container-use watch` - Monitor environment activity

### Environment Inspection

- `container-use log <environment-id>` - View commit history
- `container-use diff <environment-id>` - Show code changes

### Environment Interaction

- `container-use checkout <environment-id>` - Checkout environment branch
- `container-use terminal <environment-id>` - Open interactive shell

### Code Integration

- `container-use merge <environment-id>` - Merge environment work
- `container-use apply <environment-id>` - Stage changes without commits

### Configuration

- `container-use config` - Manage settings
- `container-use config show` - Display configuration
- `container-use config import` - Import configuration
- `container-use config base-image set` - Set base image

### System Commands

- `container-use version` - Display version
- `container-use stdio` - Start as MCP server
- `container-use completion <shell>` - Generate shell completions

## Features

- **Auto-completion** for environment IDs from `container-use list --quiet`
- **Flag completion** with descriptions
- **Command completion** with full hierarchy support
- **cu alias support** - All completions work for both `container-use` and `cu`

## Requirements

- `container-use` CLI tool must be installed and in PATH
- Nushell 0.90.0 or later

## Example Usage

```nu
# List environments with completion
container-use list<TAB>

# Delete environment with ID completion
container-use delete <TAB>

# Checkout with branch name
container-use checkout fancy-mallard --branch my-branch

# Use cu alias
cu merge <TAB>
```

## License

MIT

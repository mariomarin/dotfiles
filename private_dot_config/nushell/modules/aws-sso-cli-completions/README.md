# AWS SSO CLI Completions

Nushell completions for the aws-sso-cli tool.

## Installation

```nu
nupm install --path ~/.config/nushell/modules/aws-sso-cli-completions
```

## Usage

```nu
use aws-sso-cli-completions *
```

Completions will automatically be available for all `aws-sso` commands.

## Supported Commands

### Authentication & Session Management

- `aws-sso login` - Authenticate via AWS Identity Center
- `aws-sso logout` - Invalidate token and clear cache
- `aws-sso time` - Print credential validity duration

### Credential Management

- `aws-sso eval` - Output shell export statements for credentials
- `aws-sso exec` - Execute command with AWS credentials set
- `aws-sso process` - External credentials provider
- `aws-sso credentials` - Generate static credentials file

### Role & Account Discovery

- `aws-sso list` - Display accessible AWS roles with metadata
- `aws-sso tags` - Display roles with metadata tags
- `aws-sso cache` - Refresh cached AWS information

### AWS Console Access

- `aws-sso console` - Generate AWS Console access URL

### Setup & Configuration

- `aws-sso setup wizard` - Interactive configuration wizard
- `aws-sso setup profiles` - Generate named profiles in ~/.aws/config
- `aws-sso setup completions` - Install shell auto-completion
- `aws-sso setup ecs` - Configure ECS server

## Helper Functions

### `aws-sso-profile` - Assume Role by Profile

Quickly assume a role using profile name with auto-completion:

```nu
aws-sso-profile my-profile-name
aws-sso-profile --sso my-sso-instance my-profile
```

### `aws-sso-clear` - Clear AWS Environment

Clear all AWS-related environment variables:

```nu
aws-sso-clear
```

## Features

- **Auto-completion** for profiles, roles, and accounts from `aws-sso list`
- **Flag completion** with descriptions for all commands
- **Command hierarchy** support for all subcommands
- **Helper functions** for common workflows
- **Dynamic data** - Completions fetch live data from AWS SSO

## Requirements

- `aws-sso-cli` tool must be installed and configured
- Nushell 0.90.0 or later

## Example Usage

```nu
# Login and list available roles
aws-sso login
aws-sso list

# Assume a role interactively
aws-sso console --prompt

# Execute command with specific role
aws-sso exec --profile my-profile -- aws s3 ls

# Generate credentials for a profile
aws-sso credentials --profile my-profile

# Use helper to assume role
aws-sso-profile my-profile
```

## Configuration

The tool reads configuration from `~/.aws-sso/config.yaml`. Run the setup wizard to configure:

```nu
aws-sso setup wizard
```

## License

MIT

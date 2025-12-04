# Claude Helpers Module

Helper functions for Claude Code CLI with MCP integration, prompt improvement, and git workflows.

## Installation

```nu
nupm install --path ~/.config/nushell/modules/claude-helpers
```

## Usage

```nu
use claude-helpers *
```

## Available Commands

### `cl` - MCP Container-Use Claude

Run Claude with MCP environment and container-use enforcement:

```nu
cl "create a python environment and test some code"
```

### `improve` - Prompt Improvement

Improve a prompt for better AI understanding:

```nu
improve "make my code better"
```

### `popus` - Opus with Clipboard

Run Opus model with clipboard content:

```nu
popus "explain this code"
```

### `dopus` - Opus with Skipped Permissions

Run Opus with dangerous permissions skipped:

```nu
dopus "refactor this function"
```

### `copus` - Opus with Specific Tools

Run Opus with specific MCP tools:

```nu
copus "research this topic"
```

### `claudepool` - Deadpool Personality

Fun Deadpool-style Claude personality:

```nu
claudepool "help me debug this"
```

### `ccusage` - Usage Statistics

Show Claude usage tracking information:

```nu
ccusage
```

### `claude help` - Help Information

Display help for all commands:

```nu
claude help
```

## Aliases

- `clhelp` → `claude help`

## Requirements

- Claude Code CLI (`claude` command)
- Clipboard tool: `pbpaste` (macOS), `xclip` or `xsel` (Linux), PowerShell (Windows)

## License

MIT

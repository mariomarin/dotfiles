# Claude Helpers Module

Helper functions for Claude Code CLI.

## Usage

```nu
use claude-helpers *
```

## Commands

| Command | Description |
|---------|-------------|
| `cl` | Claude with MCP container-use |
| `improve` | Improve prompts |
| `popus` | Opus with clipboard |
| `dopus` | Opus with skipped permissions |
| `copus` | Opus with specific tools |
| `claudepool` | Deadpool personality |
| `ccusage` | Usage statistics |
| `claude help` | Show help |

## Installation

Auto-installed via nupm when running `chezmoi apply`.

## Requirements

- Claude Code CLI
- Clipboard tool (pbpaste/xclip/xsel)

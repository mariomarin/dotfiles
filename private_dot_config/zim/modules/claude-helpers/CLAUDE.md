# CLAUDE.md - Claude Helpers Module

This Zim module provides helper functions and completions for Claude Code.

## Structure

```text
claude-helpers/
├── init.zsh           # Module initialization
├── functions/         # Completion functions
│   ├── _claude        # Main claude command completion
│   ├── _cl            # Container-use enforced claude
│   ├── _improve       # Prompt improvement helper
│   ├── _popus         # Opus with clipboard
│   └── _gitblade      # Git commit assistant
├── README.md          # User documentation
└── CLAUDE.md          # This file
```

## How It Works

1. **init.zsh**:
   - Adds functions directory to fpath
   - Defines helper functions (cl, improve, popus, etc.)
   - Checks if claude command is available
   - Sources local customizations if present

2. **Completion Functions**:
   - Each helper function has its own completion
   - Uses Zsh's `_arguments` for option parsing
   - Inherits options from main _claude where appropriate

## Helper Functions

### cl - Container-Use Enforced Claude

- Runs claude with MCP environment
- Pre-configures container-use tools
- Adds system prompt for container-based development

### improve - Prompt Engineering Helper

- Takes a user prompt and improves it
- Uses sonnet model for optimization
- Returns only the improved prompt

### popus - Opus with Clipboard

- Uses clipboard content as prompt
- Works across macOS (pbpaste) and Linux (xclip/xsel)
- Accepts additional arguments

### gitblade - Git Commit Assistant

- Analyzes git changes and suggests atomic commits
- Groups related files together
- Generates conventional commit messages
- Aliases: `blade`, `gb`

### Other Helpers

- **dopus**: Opus with dangerous permissions skipped
- **copus**: Opus with specific MCP tools
- **claudepool**: Fun Deadpool personality
- **ccusage**: Usage statistics helper

## Testing

Test completions after installation:

```bash
# Reload shell or source new completions
exec zsh

# Test completions
claude <TAB>
cl <TAB>
gitblade <TAB>
```

## Maintenance

To add new helper functions:

1. Define the function in init.zsh
2. Create a completion file in functions/_functionname
3. Update this documentation

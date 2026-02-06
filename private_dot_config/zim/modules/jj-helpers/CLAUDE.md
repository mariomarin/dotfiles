# CLAUDE.md - Jujutsu Helpers Module

This Zim module provides helper functions and aliases for Jujutsu (jj) version control.

## Structure

```text
jj-helpers/
├── init.zsh           # Module initialization with aliases and functions
├── functions/         # Completion functions
│   ├── _jpr           # PR creation completion
│   ├── _jjsync        # Sync completion
│   ├── _jjst          # Status completion
│   └── _jjco          # Interactive checkout completion
├── README.md          # User documentation
└── CLAUDE.md          # This file
```

## Design Philosophy

This module mirrors the structure of zimfw's git module, providing:

1. **Short aliases** for common operations (like `jst`, `jl`, `jb`)
2. **Helper functions** for complex workflows (like `jpr`, `jjsync`)
3. **Completion support** for all functions
4. **Consistency** with git module patterns

## Key Features

### Bookmark-Centric Workflow

Jujutsu uses "bookmarks" instead of git branches. The module provides:

- `jb*` aliases for bookmark operations
- `jpr` function that auto-detects current bookmark for PRs
- `jjco` for interactive bookmark selection with fzf

### GitHub Integration

The `jpr` function integrates with `gh` CLI, inspired by git-branchless `submit`:

- Auto-detects current bookmark name
- Creates new PRs with `-c/--create` flag
- Updates existing PRs by force-pushing
- Supports draft PRs with `-d/--draft`
- Can process multiple bookmarks with `-a/--all`
- Checks if PR exists before creating
- Passes through all `gh pr create` options

### Sync Workflow

The `jjsync` function provides a sync workflow, inspired by git-branchless `sync`:

1. Fetch latest changes from git remote (optional with `--no-pull`)
2. Rebase bookmark(s) onto main
3. Supports syncing all bookmarks with `-a/--all`
4. Can sync specific bookmark by name

## Implementation Details

### init.zsh

- Checks for jj command availability before loading
- Defines aliases alphabetically for maintainability
- Functions use proper error handling
- Supports local customizations via `local.zsh`

### Completion Functions

- Minimal completions for custom functions
- `_jpr` attempts to inherit `gh pr create` completions
- Uses `_message` for simple function descriptions

## Adding New Functions

To add a new helper function:

1. Add function to init.zsh in the Functions section
2. Create completion file in `functions/_functionname`
3. Update README.md and help function
4. Test with `exec zsh` and tab completion

## Testing

```bash
# Reload shell to test changes
exec zsh

# Test aliases
jst<TAB>
jl<TAB>

# Test functions
jpr<TAB>
jjsync<TAB>

# Verify module loaded
jjhelp
```

## Common Patterns

### Error Handling

```bash
# Check for required commands
if ! (( $+commands[fzf] )); then
    echo "Error: fzf is required" >&2
    return 1
fi
```

### Command Detection

```bash
# Only load if jj exists
if (( ! ${+commands[jj]} )); then
    return 0
fi
```

### Subcommand Execution

```bash
# Capture command output
local result
result=$(jj log -r @ --no-graph -T 'bookmarks')

# Check for empty result
if [[ -z "$result" ]]; then
    echo "Error message" >&2
    return 1
fi
```

## Related Documentation

- [Zim CLAUDE.md](../../CLAUDE.md)
- [Jujutsu Documentation](https://martinvonz.github.io/jj/)
- [GitHub CLI Documentation](https://cli.github.com/)

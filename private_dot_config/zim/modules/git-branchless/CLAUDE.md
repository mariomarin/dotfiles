# CLAUDE.md - Git Branchless Completion Module

This Zim module provides Zsh command completion for git-branchless.

## Structure

```text
git-branchless/
├── init.zsh           # Module initialization
├── functions/
│   └── _git-branchless # Completion function
├── README.md          # User documentation
└── CLAUDE.md          # This file
```

## How It Works

1. **init.zsh**:
   - Adds the functions directory to fpath
   - Checks if git-branchless is installed
   - Returns early if not available

2. **functions/_git-branchless**:
   - Defines completion for all git-branchless subcommands
   - Uses Zsh's `_arguments` for option parsing
   - Provides context-aware completions
   - Integrates with git completion helpers

## Completion Features

- Subcommand completion with descriptions
- Option completion with short and long forms
- Context-sensitive argument completion
- Integration with git completion for commits/branches
- Support for revset arguments

## Testing

Test the completion by:

```bash
# After installing the module
zimfw install

# Start new shell
exec zsh

# Test completion
git-branchless <TAB>
git-branchless amend --<TAB>
```

## Maintenance

To update completions for new git-branchless versions:

1. Check git-branchless --help for new commands
2. Update the completion function in functions/_git-branchless
3. Test all command completions

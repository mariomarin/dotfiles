# git-branchless Completions

Nushell completions for git-branchless workflow tools.

## Installation

```nu
nupm install --path ~/.config/nushell/modules/git-branchless-completions
```

## Usage

```nu
use git-branchless-completions *
```

Completions will automatically be available for all `git branchless` subcommands.

## Supported Commands

### Workflow Commands

- `git branchless smartlog` (alias: `git sl`) - Display repository state visually
- `git branchless next` - Move to later commit in stack
- `git branchless prev` - Move to earlier commit in stack
- `git branchless switch` - Switch to branch or commit
- `git branchless sync` - Move local stacks on top of main branch

### Commit Management

- `git branchless amend` - Amend the current HEAD commit
- `git branchless record` - Create commit interactively
- `git branchless reword` - Reword commits
- `git branchless move` - Move subtree of commits

### Stack Management

- `git branchless restack` - Fix abandoned commits
- `git branchless hide` - Hide commits from smartlog
- `git branchless unhide` - Unhide previously-hidden commits

### Utilities

- `git branchless undo` - Browse or return to previous state
- `git branchless query` - Query commit graph using revset language
- `git branchless test` - Run command on each commit
- `git branchless submit` - Push commits to remote

### Setup & Maintenance

- `git branchless init` - Initialize branchless workflow
- `git branchless gc` - Run internal garbage collection
- `git branchless repair` - Restore internal invariants
- `git branchless wrap` - Wrap Git command in transaction
- `git branchless bug-report` - Gather information for bug reports
- `git branchless difftool` - Use as Git-compatible difftool
- `git branchless install-man-pages` - Install man pages

## Features

- **Command completion** for all git-branchless subcommands
- **Flag completion** with descriptions
- **Interactive mode** support (-i flag)
- **Commit arguments** for commands that operate on commits

## Requirements

- `git-branchless` tool must be installed
- Git repository initialized with `git branchless init`
- Nushell 0.90.0 or later

## Example Usage

```nu
# Display smartlog
git sl

# Move to next commit in stack
git branchless next

# Move to previous commit
git branchless prev

# Sync all local stacks
git branchless sync --pull

# Interactively undo operations
git branchless undo --interactive

# Reword a commit
git branchless reword HEAD

# Hide commits from smartlog
git branchless hide abc123 def456

# Query commits
git branchless query "draft() & mine()"
```

## Workflow

git-branchless provides a high-velocity, monorepo-scale workflow for Git:

1. **Initialize**: `git branchless init` in your repository
2. **View work**: `git sl` to see your commit stacks
3. **Navigate**: Use `git prev`/`git next` to move between commits
4. **Edit**: Make changes and `git branchless amend` to update
5. **Sync**: `git branchless sync` to rebase on latest main
6. **Submit**: `git branchless submit` to create pull requests

## Documentation

For more information, see:

- [git-branchless Wiki](https://github.com/arxanas/git-branchless/wiki)
- [Tutorial](https://github.com/arxanas/git-branchless/wiki/Tutorial)
- [Concepts](https://github.com/arxanas/git-branchless/wiki/Concepts)

## License

MIT

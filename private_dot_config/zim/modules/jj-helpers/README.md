# Jujutsu (jj) Helper Module

Zim module providing aliases and helper functions for Jujutsu (jj) version control, mirroring the structure of the git module.

## Overview

This module provides git-branchless style workflows for Jujutsu, including:

- **Divergent development** - Make speculative commits, backtrack, try different approaches
- **Stack editing** - Edit commits in the middle of a stack
- **Navigation** - Move through commit history with prev/next
- **Branchless workflow** - Work without local branches, push directly

## Quick Start: Common Workflows

### Daily Development

```bash
jsl                 # View commit graph (smartlog)
jn -m "new work"    # Create new change
jd -m "description" # Describe current change
jdiff               # View changes
```

### Navigate Stack

```bash
jprev               # Move to parent commit
jnext               # Move to child commit
jsl                 # See where you are
```

### Edit Old Commit

```bash
je <commit>         # Edit old commit (descendants auto-rebase!)
# ... make changes ...
jd -m "updated"     # Describe changes
```

### Squash Changes

```bash
jsq                 # Squash current into parent
jsqi                # Interactive squash
je <commit>         # Edit commit, make changes, jj auto-squashes
```

### Move Commits

```bash
jmove feature-2 feature-1    # Move feature-2 after feature-1 (with descendants)
jmove -r fix main            # Move single fix to main
```

### Sync and Push

```bash
jjsync              # Fetch and rebase on main
jbc my-feature      # Create bookmark
jpr -c              # Create PR
jpr                 # Update existing PR
jpush               # Push bookmark to remote
```

### Undo Mistakes

```bash
jundo               # Undo last operation
joplog              # View operation history
jredo               # Redo operation
```

### Hide Experiments

```bash
jab <commit>        # Abandon/hide failed experiment
junhide <commit>    # Restore if needed
```

## Aliases

### Navigation

| Alias   | Command     | Description        |
| ------- | ----------- | ------------------ |
| `jprev` | `jj prev`   | Move to parent     |
| `jnext` | `jj next`   | Move to child      |

### Viewing

| Alias   | Command                        | Description            |
| ------- | ------------------------------ | ---------------------- |
| `jsl`   | `jj log -r "all()" --limit 20` | Smartlog view          |
| `jl`    | `jj log`                       | Log view               |
| `jlg`   | `jj log --graph`               | Log with graph         |
| `jdiff` | `jj diff`                      | Show diff              |
| `jde`   | `jj diffedit`                  | Interactive diff edit  |

### Bookmark Operations

| Alias    | Command               | Description            |
| -------- | --------------------- | ---------------------- |
| `jb`     | `jj bookmark`         | Bookmark commands      |
| `jbc`    | `jj bookmark create`  | Create a bookmark      |
| `jbd`    | `jj bookmark delete`  | Delete a bookmark      |
| `jbl`    | `jj bookmark list`    | List bookmarks         |
| `jbm`    | `jj bookmark move`    | Move a bookmark        |
| `jbset`  | `jj bookmark set`     | Set bookmark to @      |
| `jbtrack`| `jj bookmark track`   | Track remote bookmark  |

### Change Operations

| Alias  | Command            | Description             |
| ------ | ------------------ | ----------------------- |
| `jc`   | `jj commit`        | Commit changes          |
| `jd`   | `jj describe`      | Describe/reword commit  |
| `jn`   | `jj new`           | Create new change       |
| `je`   | `jj edit`          | Edit old commit         |
| `jsq`  | `jj squash`        | Squash into parent      |
| `jsqi` | `jj squash -i`     | Interactive squash      |
| `jsqf` | `jj squash --from` | Squash from commit      |

### Status

| Alias  | Command     | Description  |
| ------ | ----------- | ------------ |
| `jst`  | `jj status` | Show status  |

### Rebase/Move Operations

| Alias  | Command            | Description                    |
| ------ | ------------------ | ------------------------------ |
| `jrb`  | `jj rebase`        | Rebase changes                 |
| `jrbi` | `jj rebase -d`     | Rebase to destination          |
| `jrbs` | `jj rebase -s`     | Rebase source + descendants    |
| `jrbr` | `jj rebase -r`     | Rebase single commit only      |

### Insert Operations

| Alias  | Command                  | Description            |
| ------ | ------------------------ | ---------------------- |
| `jins` | `jj new --insert-after`  | Insert after commit    |
| `jinb` | `jj new --insert-before` | Insert before commit   |

### Hide/Abandon

| Alias     | Command       | Description            |
| --------- | ------------- | ---------------------- |
| `jab`     | `jj abandon`  | Abandon/hide commits   |
| `junhide` | `jj restore`  | Restore abandoned      |

### Undo/Redo

| Alias    | Command          | Description         |
| -------- | ---------------- | ------------------- |
| `jundo`  | `jj op undo`     | Undo operation      |
| `jredo`  | `jj op restore`  | Redo operation      |
| `jop`    | `jj op`          | Operation commands  |
| `joplog` | `jj op log`      | Operation log       |

### Git Operations

| Alias  | Command          | Description           |
| ------ | ---------------- | --------------------- |
| `jgf`  | `jj git fetch`   | Fetch from git remote |
| `jgp`  | `jj git push`    | Push to git remote    |

## Functions

### jmove

Move commits in the stack (git-branchless `move` equivalent).

```bash
jmove [-s|-r] <commit> <dest>
```

**Options:**

- `-s, --source` - Move commit and descendants (default)
- `-r, -x, --exact` - Move single commit only

**Examples:**

```bash
jmove feature-3 feature-2      # Move feature-3 + descendants after feature-2
jmove -r fix-typo feature-1    # Move single commit into stack
```

### jpush

Push current bookmark to remote.

```bash
jpush [additional git push options]
```

Detects current bookmark and pushes it. Errors if no bookmark exists.

### jpush-main

Set main bookmark to current change and push.

```bash
jpush-main
```

Equivalent to: `jj bookmark set main && jj git push --bookmark main`

### jpr

Create or update GitHub PRs from jj bookmark(s). Inspired by git-branchless `submit`.

```bash
jpr [options] [bookmark]
```

**Options:**

- `-c, --create` - Create PR if it doesn't exist (otherwise only updates)
- `-d, --draft` - Create as draft PR
- `-a, --all` - Process all bookmarks instead of just current

**Behavior:**

- If PR exists for bookmark, force-pushes to update it
- If PR doesn't exist and `--create` is passed, creates new PR
- Without arguments, uses current bookmark (@)
- Pass other `gh pr create` flags (like `--title`, `--body`)

**Examples:**

```bash
jpr -c              # Create PR for current bookmark
jpr -c -d           # Create draft PR
jpr -a -c           # Create PRs for all bookmarks
jpr my-feature      # Update PR for specific bookmark
```

### jjsync

Fetch from remote and rebase bookmark(s) on main. Inspired by git-branchless `sync`.

```bash
jjsync [options] [bookmark]
```

**Options:**

- `-p, --pull` - Fetch from remote first (default)
- `--no-pull` - Skip fetch
- `-a, --all` - Sync all bookmarks

**Behavior:**

- Default: fetches and rebases current change (@) on main
- With bookmark name: rebases that bookmark
- With `--all`: rebases all bookmarks on main

**Examples:**

```bash
jjsync              # Sync current change
jjsync --no-pull    # Sync without fetching
jjsync -a           # Sync all bookmarks
jjsync my-feature   # Sync specific bookmark
```

### jjst

Show status with recent log (last 5 ancestors).

```bash
jjst
```

### jjco

Interactive bookmark checkout using fzf.

```bash
jjco
```

Requires `fzf` to be installed.

### jjhelp

Show help for all jj helpers.

```bash
jjhelp
```

## Examples

### Basic Workflow

```bash
# Create a new change and bookmark
jn -m "working on feature"
jbc my-feature

# Make changes, describe them
jd -m "implement feature X"

# Sync with main
jjsync

# Create PR
jpr -c

# Update PR after more changes
jd -m "address review comments"
jpr                    # Updates existing PR

# Interactive bookmark selection
jjco
```

### Stack Workflow (git-branchless style)

```bash
# Create multiple features as bookmarks
jn -m "feature 1" && jbc feature-1
jn -m "feature 2" && jbc feature-2
jn -m "feature 3" && jbc feature-3

# Sync all bookmarks with main
jjsync -a

# Create PRs for all features at once
jpr -a -c

# Later, update all PRs after rebasing
jjsync -a
jpr -a
```

## Workflows

### Divergent Development

Make speculative commits and try different approaches (git-branchless style).

```bash
# Make speculative changes
jn -m "temp: approach 1"
jn -m "temp: approach 2"
jsl                    # View the tree

# Backtrack to try different approach
jprev 2
jn -m "temp: different approach"
jsl

# Hide abandoned approach
jab <commit-id>

# Undo if needed
jundo
```

**Key benefits:**

- Jujutsu doesn't need `git checkout --detach` - works detachless by default
- No `git restack` needed - descendants auto-rebase
- Use `jundo` to time-travel

### Editing Old Commits

Edit commits in the middle of a stack.

```bash
# View your stack
jsl

# Approach 1: Edit commit directly
je <commit-id>        # Edit old commit
# ...make changes...
jd -m "updated"       # Describe changes
# Descendants auto-rebase! No manual restack needed

# Approach 2: Make child commit, squash later
jn <commit-id>        # New change at commit
# ...make changes...
jd -m "temp: address feedback"
jsq                   # Squash into parent

# Approach 3: Commute patch upward
jn -m "temp: fix for earlier commit"
jmove -r @ <target-commit>  # Move fix to target
jsq                         # Squash into target
```

### Branchless Workflow

Work without local branches, push directly.

```bash
# Sync with main
jjsync              # Fetch + rebase on main

# Option 1: Push to main directly
jpush-main          # Set main to @ and push

# Option 2: Work with remote main
jjsync              # Sync with origin/main
jpr -c              # Create PR from bookmark

# Option 3: Create temporary bookmark for PR
jbc temp            # Create bookmark
jpr -c              # Create PR
```

### Stack Manipulation

Insert and move commits within stacks.

```bash
# Create stack
jn -m "feature 1" && jbc feature-1
jn -m "feature 2" && jbc feature-2
jn -m "feature 3" && jbc feature-3

# Insert commit in middle
je feature-1        # Edit feature-1
jn -m "new work"    # Create after feature-1
jmove -s feature-2  # Move feature-2+ after new work

# Move single commit
jmove -r feature-3 feature-1  # Insert feature-3 after feature-1

# Sync and push all
jjsync -a           # Sync all bookmarks
jpr -a -c           # Create PRs for all
```

## Installation

This module is automatically loaded via zimrc when jj is installed.

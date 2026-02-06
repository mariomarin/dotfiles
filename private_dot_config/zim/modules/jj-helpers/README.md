# Jujutsu (jj) Helper Module

Zim module providing aliases and helper functions for Jujutsu (jj) version control, mirroring the structure of the git module.

## Aliases

### Bookmark Operations

| Alias  | Command               | Description            |
| ------ | --------------------- | ---------------------- |
| `jb`   | `jj bookmark`         | Bookmark commands      |
| `jbc`  | `jj bookmark create`  | Create a bookmark      |
| `jbd`  | `jj bookmark delete`  | Delete a bookmark      |
| `jbl`  | `jj bookmark list`    | List bookmarks         |
| `jbm`  | `jj bookmark move`    | Move a bookmark        |

### Change Operations

| Alias  | Command        | Description             |
| ------ | -------------- | ----------------------- |
| `jc`   | `jj commit`    | Commit changes          |
| `jd`   | `jj describe`  | Describe current change |
| `jn`   | `jj new`       | Create new change       |

### Diff and Status

| Alias   | Command      | Description  |
| ------- | ------------ | ------------ |
| `jdiff` | `jj diff`    | Show diff    |
| `jst`   | `jj status`  | Show status  |

### Log

| Alias  | Command            | Description          |
| ------ | ------------------ | -------------------- |
| `jl`   | `jj log`           | Show log             |
| `jlg`  | `jj log --graph`   | Show log with graph  |

### Rebase

| Alias   | Command         | Description            |
| ------- | --------------- | ---------------------- |
| `jrb`   | `jj rebase`     | Rebase changes         |
| `jrbi`  | `jj rebase -d`  | Rebase to destination  |

### Git Operations

| Alias  | Command          | Description           |
| ------ | ---------------- | --------------------- |
| `jgf`  | `jj git fetch`   | Fetch from git remote |
| `jgp`  | `jj git push`    | Push to git remote    |

## Functions

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

## Installation

This module is automatically loaded via zimrc when jj is installed.

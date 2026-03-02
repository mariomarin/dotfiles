# jj-core

Core Jujutsu utilities for zim modules. Provides shared revset builders (string composition) and query executors (jj commands).

## Design Philosophy

This module separates revset construction from execution:

- **Revset Builders**: Construct revset expressions through string composition (no I/O)
- **Query Executors**: Execute jj commands (I/O operations)

### Why This Separation?

Jujutsu revsets are declarative and composable:
- Describe WHAT to query, not HOW to execute
- Compose complex queries: `mine() & conflicted()`, `trunk()..mutable()`
- Same revset → same result (for given repo state)
- Can be constructed and validated without executing jj

## API

### Constants

```zsh
JJ_DEFAULT_BASE="trunk()"
JJ_PROMPT_NO_BOOKMARK="[jj]"
JJ_PROMPT_SEPARATOR="›"
```

### Revset Builders

Construct revset expressions (string composition, no I/O):

```zsh
_jj_revset_conflicts [scope]
  # Build revset to find conflicted changes
  # scope defaults to "mutable()"

_jj_revset_local_work <base> <mine_only>
  # Build revset for local uncommitted work
  # mine_only: true/false

_jj_revset_bookmark_ancestors [commit]
  # Build revset to find bookmarks in ancestry
  # commit defaults to "@"

_jj_revset_closest_bookmark
  # Build revset to find closest bookmark (local, remote, or trunk)

_jj_revset_distance <from> [to]
  # Build revset to count distance between commits
  # to defaults to "@"

_jj_revset_all_local [base]
  # Build revset for all local changes in range
```

### Query Executors

Execute jj commands (I/O operations):

```zsh
_jj_in_repo
  # Check if in jj repository
  # Returns: 0 if in repo, 1 otherwise

_jj_workspace_root
  # Get workspace root path

_jj_query <revset> <template> [options...]
  # Execute jj log query

_jj_query_first <revset> <template> [options...]
  # Execute query and return first line

_jj_query_count <revset>
  # Count commits matching revset

_jj_query_bookmark [revset]
  # Query for bookmark name
  # revset defaults to "@"

_jj_query_conflicted [scope]
  # Query for conflicted commits
  # scope defaults to "mutable()"

_jj_query_closest_bookmark
  # Find closest bookmark (local, remote, or trunk)

_jj_query_distance <from> [to]
  # Calculate distance from bookmark to commit
```

### Repository Operations

```zsh
_jj_rebase <mode> <source> <destination>
  # Execute rebase operation
  # mode: -s (with descendants), -r (single commit), -b (branch), -d (current)

_jj_operation_undo
  # Undo last jj operation
```

## Usage

Load before other jj modules in `.zimrc`:

```zsh
zmodule ${ZIM_CONFIG_FILE:h}/modules/jj-core
zmodule ${ZIM_CONFIG_FILE:h}/modules/jj-info
zmodule ${ZIM_CONFIG_FILE:h}/modules/jj-helpers
```

## Example

```zsh
# Build revset (string composition)
local revset=$(_jj_revset_conflicts "mutable()")

# Execute query (I/O operation)
local conflicts=$(_jj_query "$revset" 'commit_id.short()')

# Composed operations
local closest=$(_jj_query_closest_bookmark)
local distance=$(_jj_query_distance "$closest")
```

## Benefits

- **Testable**: Revset builders work without executing jj
- **Reusable**: Same builders work for query, rebase, diff operations
- **Composable**: Build complex revsets from simple ones
- **Separated concerns**: Query construction vs execution
- **DRY**: Shared across all jj modules

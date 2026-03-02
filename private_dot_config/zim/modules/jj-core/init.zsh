# jj-core - Core Jujutsu utilities for zim modules
# Provides revset builders (string composition) and query executors (jj commands)
# Shared by jj-info, jj-helpers, and jj-gitster modules

# Only proceed if jj command exists
(( ${+commands[jj]} )) || return 0

# Directory for module functions
JJ_CORE_DIR="${0:h}/functions"

# Create functions directory if it doesn't exist
[[ -d "$JJ_CORE_DIR" ]] || mkdir -p "$JJ_CORE_DIR"

# Add to fpath for autoloading
fpath=("$JJ_CORE_DIR" "${fpath[@]}")

#
# Constants
#

typeset -g JJ_DEFAULT_BASE="trunk()"
typeset -g JJ_PROMPT_NO_BOOKMARK="[jj]"
typeset -g JJ_PROMPT_SEPARATOR="›"

#
# Revset Builders
# Construct revset expressions (string composition, no I/O)
#

_jj_revset_conflicts() {
    # Build revset to find conflicted changes
    # Args: $1 = scope (default: "mutable()")
    # Returns: revset string
    local scope="${1:-mutable()}"
    echo "$scope & conflicts()"
}

_jj_revset_local_work() {
    # Build revset for local uncommitted work
    # Args: $1 = base bookmark, $2 = mine_only (true/false)
    # Returns: revset string
    local base="${1:-trunk()}"
    local mine_only="$2"

    if [[ "$mine_only" == true ]]; then
        echo "${base}..mine()"
    else
        echo "${base}..mutable()"
    fi
}

_jj_revset_bookmark_ancestors() {
    # Build revset to find bookmarks in ancestry
    # Args: $1 = commit (default: "@")
    # Returns: revset string
    local commit="${1:-@}"
    echo "::${commit} & bookmarks()"
}

_jj_revset_closest_bookmark() {
    # Build revset to find closest bookmark (local, remote, or trunk)
    # Args: none
    # Returns: revset string
    echo "coalesce(
        heads(::@ & bookmarks()),
        heads(::@ & remote_bookmarks()),
        trunk()
    )"
}

_jj_revset_distance() {
    # Build revset to count distance between commits
    # Args: $1 = from bookmark, $2 = to commit (default: "@")
    # Returns: revset string
    local from="$1"
    local to="${2:-@}"

    [[ -z "$from" ]] && return 1
    echo "$from..$to & (~empty() | merges())"
}

_jj_revset_all_local() {
    # Build revset for all local changes in range
    # Args: $1 = base bookmark
    # Returns: revset string
    local base="${1:-trunk()}"
    echo "${base}..mutable()"
}

#
# Query Executors
# Execute jj commands (I/O operations)
#

_jj_in_repo() {
    # Check if current directory is in a jj repository
    # Returns: 0 if in repo, 1 otherwise
    jj workspace root &>/dev/null
}

_jj_workspace_root() {
    # Get workspace root path
    # Returns: workspace path or empty string
    jj workspace root 2>/dev/null
}

_jj_query() {
    # Execute a jj log query with given revset and template
    # Args: $1 = revset, $2 = template, $3... = additional jj log options
    # Returns: query output
    local revset="$1"
    local template="$2"
    shift 2

    jj log -r "$revset" -T "$template" --no-graph --color never "$@" 2>/dev/null
}

_jj_query_first() {
    # Execute query and return only first line
    # Args: same as _jj_query
    # Returns: first line of query output
    local -a output
    output=(${(f)"$(_jj_query "$@")"})
    echo "${output[1]}"
}

_jj_query_count() {
    # Execute query and count results
    # Args: $1 = revset
    # Returns: count of matching commits
    local revset="$1"
    local output
    output=$(_jj_query "$revset" '"n"')
    echo ${#output}
}

_jj_query_bookmark() {
    # Query for bookmark name using a revset
    # Args: $1 = revset
    # Returns: bookmark name or empty string
    local revset="${1:-@}"
    _jj_query_first "$revset" 'separate(" ", bookmarks)'
}

_jj_query_conflicted() {
    # Query for conflicted commits
    # Args: $1 = scope (default: "mutable()")
    # Returns: list of conflicted commit IDs, one per line
    local scope="${1:-mutable()}"
    local revset
    revset=$(_jj_revset_conflicts "$scope")
    _jj_query "$revset" 'commit_id.short() ++ "\n"'
}

_jj_query_closest_bookmark() {
    # Find the closest bookmark (local, remote, or trunk)
    # Returns: bookmark name or empty string
    local revset
    revset=$(_jj_revset_closest_bookmark)
    _jj_query_first "$revset" 'separate(" ", bookmarks)'
}

_jj_query_distance() {
    # Calculate distance from bookmark to commit
    # Args: $1 = from bookmark, $2 = to commit (default: "@")
    # Returns: number of commits
    local from="$1"
    local to="${2:-@}"

    [[ -z "$from" ]] && return 1

    local revset
    revset=$(_jj_revset_distance "$from" "$to")
    _jj_query_count "$revset"
}

#
# Repository Operations
#

_jj_rebase() {
    # Execute rebase operation
    # Args: $1 = mode (-s, -r, -b, -d), $2 = source, $3 = destination
    # Returns: exit code from jj rebase
    local mode="$1"
    local source="$2"
    local dest="$3"

    if [[ "$mode" == "-d" ]]; then
        # -d mode doesn't take a source
        jj rebase -d "$dest"
    else
        jj rebase "$mode" "$source" -d "$dest"
    fi
}

_jj_operation_undo() {
    # Undo the last jj operation
    # Returns: exit code from jj op undo
    jj op undo
}

# Source local customizations if they exist
[[ -f "${0:h}/local.zsh" ]] && source "${0:h}/local.zsh"

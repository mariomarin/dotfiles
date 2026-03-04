# Jujutsu (jj) Helper Module for Zimfw
# Mirrors git module structure with jj-specific aliases and functions

# Directory for module functions
JJ_HELPERS_DIR="${0:h}/functions"

# Create functions directory if it doesn't exist
[[ -d "$JJ_HELPERS_DIR" ]] || mkdir -p "$JJ_HELPERS_DIR"

# Add to fpath for autoloading
fpath=("$JJ_HELPERS_DIR" "${fpath[@]}")

# Only proceed if jj command exists
(( ${+commands[jj]} )) || return 0

#
# Aliases
#

# Bookmark (b)
alias jb='jj bookmark'
alias jbc='jj bookmark create'
alias jbd='jj bookmark delete'
alias jbl='jj bookmark list'
alias jbm='jj bookmark move'
alias jbset='jj bookmark set'
alias jbtrack='jj bookmark track'

# Change (c)
alias jc='jj commit'
alias jd='jj describe'
alias jn='jj new'
alias je='jj edit'
alias jsq='jj squash'
alias jsqi='jj squash -i'
alias jsqf='jj squash --from'

# Diff (d)
alias jdiff='jj diff'
alias jde='jj diffedit'
alias jst='jj status'

# Log (l)
alias jl='jj log'
alias jlg='jj log --graph'
alias jsl='jj log -r "all()" --limit 20'

# Navigation (n)
alias jprev='jj prev'
alias jnext='jj next'

# Rebase (r)
alias jrb='jj rebase'
alias jrbi='jj rebase -d'
alias jrbs='jj rebase -s'
alias jrbr='jj rebase -r'

# Insert (i)
alias jins='jj new --insert-after'
alias jinb='jj new --insert-before'

# Abandon/hide (a)
alias jab='jj abandon'
alias junhide='jj restore'

# Operation log (o)
alias jop='jj op'
alias joplog='jj op log'
alias jundo='jj op undo'
alias jredo='jj op restore'

# Git operations (g)
alias jgf='jj git fetch --tracked'
alias jgp='jj git push --tracked'

#
# Helper Functions
#

_jj-get-current-bookmark() {
    local bookmark
    bookmark=$(jj log -r @ --no-graph -T 'bookmarks' 2>/dev/null)

    # Return immediately if current change has a bookmark
    if [[ -n "$bookmark" ]]; then
        echo "$bookmark"
        return 0
    fi

    # Check if it's an empty commit on top of a bookmarked parent
    local is_empty
    is_empty=$(jj log -r @ --no-graph -T 'if(empty, "true", "")' 2>/dev/null)

    if [[ "$is_empty" != "true" ]]; then
        echo "Error: No bookmark found for current change (@)" >&2
        echo "Create a bookmark first: jj bookmark create <name>" >&2
        return 1
    fi

    # Try parent's bookmark
    bookmark=$(jj log -r '@-' --no-graph -T 'bookmarks' 2>/dev/null)
    if [[ -n "$bookmark" ]]; then
        echo "Note: Using parent bookmark ($bookmark) since @ is empty" >&2
        echo "$bookmark"
        return 0
    fi

    echo "Error: No bookmark found for current change (@) or parent (@-)" >&2
    echo "Create a bookmark first: jj bookmark create <name>" >&2
    return 1
}

_jj-get-all-bookmarks() {
    # Get local bookmarks only (not indented), strip trailing colon
    local -a lines
    lines=(${(f)"$(jj bookmark list)"})
    # Filter non-indented lines, extract first field, strip colon
    print -l ${${${(M)lines:#[^[:space:]]*}%% *}%:}
}

_jj-show-status() {
    # Display current state of local work
    # Args: $1 = base bookmark (default: "trunk()")
    local base="${1:-trunk()}"
    local revset
    revset=$(_jj_revset_all_local "$base")
    echo "📊 Current state:"
    jj log -r "$revset" --limit 10 2>/dev/null || jj log --limit 10
}

_jj-get-pr-number() {
    # Get PR number for a bookmark, if it exists
    # Args: $1 = bookmark name
    # Returns: PR number or empty string
    local bookmark="$1"
    command gh pr list --head "$bookmark" --json number --jq '.[0].number' 2>/dev/null
}

_jj-update-pr() {
    # Update existing PR by force-pushing bookmark
    # Args: $1 = bookmark name
    local bookmark="$1"
    jj git push --bookmark "$bookmark" --force
}

_jj-create-pr() {
    # Create new PR for bookmark
    # Args: $1 = bookmark name, $2+ = additional gh args
    local bookmark="$1"
    shift
    command gh pr create --head "$bookmark" --fill "$@"
}


#
# Functions
#

# Create or update PR from jj bookmark(s)
jpr() {
    local create=false
    local all=false
    local bookmark=""
    local gh_args=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--create) create=true; shift ;;
            -d|--draft) gh_args+=(--draft); shift ;;
            -a|--all) all=true; shift ;;
            -*) gh_args+=("$1"); shift ;;
            *) bookmark="$1"; shift ;;
        esac
    done

    local bookmarks=()
    if [[ "$all" == true ]]; then
        bookmarks=($(_jj-get-all-bookmarks))
    elif [[ -n "$bookmark" ]]; then
        bookmarks=("$bookmark")
    else
        bookmarks=($(_jj-get-current-bookmark)) || return 1
    fi

    local exit_code=0
    for bm in "${bookmarks[@]}"; do
        echo "Processing bookmark: $bm"

        local pr_number
        pr_number=$(_jj-get-pr-number "$bm")

        if [[ -n "$pr_number" ]]; then
            echo "  PR #$pr_number exists, updating..."
            _jj-update-pr "$bm" || exit_code=$?
            continue
        fi

        if [[ "$create" != true ]]; then
            echo "  No PR found. Use --create to create one." >&2
            exit_code=1
            continue
        fi

        echo "  Creating new PR..."
        _jj-create-pr "$bm" "${gh_args[@]}" || exit_code=$?
    done

    return $exit_code
}

# Sync with remote: fetch and rebase all local work on trunk (idiomatic jj way)
# Usage: jjsync [-p|--pull] [-c|--current] [-m|--mine] [-b|--base <bookmark>] [bookmark]
jjsync() {
    local pull=true
    local current_only=false
    local mine_only=false
    local bookmark=""
    local base_bookmark="trunk()"

    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--pull) pull=true; shift ;;
            --no-pull) pull=false; shift ;;
            -c|--current) current_only=true; shift ;;
            -m|--mine) mine_only=true; shift ;;
            -b|--base) base_bookmark="$2"; shift 2 ;;
            *) bookmark="$1"; shift ;;
        esac
    done

    if [[ "$pull" == true ]]; then
        echo "⏬ Fetching from remote..."
        jj git fetch --all-remotes || return
    fi

    # Show what trunk() resolved to for transparency
    local trunk_info
    trunk_info=$(jj log -r "$base_bookmark" --no-graph -T 'bookmarks ++ " " ++ commit_id.short(8)' --limit 1 2>/dev/null)
    [[ -n "$trunk_info" ]] && echo "🎯 Base: ${trunk_info}"

    # Sync specific bookmark if provided
    if [[ -n "$bookmark" ]]; then
        echo "Syncing bookmark: $bookmark"
        jj rebase -b "$bookmark" -d "$base_bookmark"
        return
    fi

    # Sync only current change if -c/--current flag
    if [[ "$current_only" == true ]]; then
        echo "Syncing current change (@)"
        jj rebase -d "$base_bookmark"
        return
    fi

    # Default: sync all local work using idiomatic jj revsets
    echo "♻️  Rebasing all local work onto trunk..."

    # Build revset for stack roots only - preserves linear topology
    local revset
    if [[ "$mine_only" == true ]]; then
        revset="roots(${base_bookmark}..mine())"
    else
        revset="roots(${base_bookmark}..mutable())"
    fi

    # Rebase stack roots - descendants follow automatically
    local rebase_output
    rebase_output=$(jj rebase -s "$revset" -d "$base_bookmark" 2>&1)
    local rebase_exit=$?

    if [[ $rebase_exit -ne 0 ]]; then
        echo "❌ Rebase failed" >&2
        echo "$rebase_output" >&2
        return 1
    fi

    # Check for conflicts (normal in jj, not an error)
    local conflict_revset="${base_bookmark}..mutable() & conflicts()"
    local -a conflicted_commits
    conflicted_commits=(${(f)"$(jj log -r "$conflict_revset" --no-graph -T 'change_id.short()' 2>/dev/null)"})

    if [[ ${#conflicted_commits[@]} -gt 0 ]]; then
        echo "⚠️  ${#conflicted_commits[@]} commit(s) have conflicts (resolve at your leisure):"
        jj log -r "$conflict_revset"
    else
        echo "✅ Sync complete - no conflicts"
    fi

    echo ""
    _jj-show-status "$base_bookmark"
    return 0
}

# Quick status with log
jjst() {
    jj status
    echo ""
    jj log -r 'ancestors(@, 5)'
}

# Interactive bookmark selection
jjco() {
    (( ${+commands[fzf]} )) || {
        echo "Error: fzf is required" >&2
        return 1
    }

    local bookmark
    bookmark=$(jj bookmark list | fzf --height=20 --reverse)
    # Extract first field and strip colon
    bookmark=${${bookmark%% *}%:}
    [[ -n "$bookmark" ]] && jj new "$bookmark"
}

# Move commits (git-branchless style)
# Usage: jmove [-s|-r] <commit> <dest>
# -s: move commit and descendants (source)
# -r: move single commit only (revisions)
jmove() {
    local mode="-s"
    local commit=""
    local dest=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--source) mode="-s"; shift ;;
            -r|-x|--exact) mode="-r"; shift ;;
            *)
                [[ -z "$commit" ]] && { commit="$1"; shift; continue; }
                [[ -z "$dest" ]] && { dest="$1"; shift; continue; }
                echo "Error: Too many arguments" >&2
                echo "Usage: jmove [-s|-r] <commit> <dest>" >&2
                return 1
                ;;
        esac
    done

    [[ -z "$commit" || -z "$dest" ]] && {
        echo "Error: Missing required arguments" >&2
        echo "Usage: jmove [-s|-r] <commit> <dest>" >&2
        return 1
    }

    echo "Moving $commit (mode: $mode) to $dest"
    jj rebase "$mode" "$commit" -d "$dest"
}

# Push to main branch
jpush-main() {
    echo "Setting main bookmark to current change and pushing..."
    jj bookmark set main || return
    jj git push --bookmark main
}

# Push current change to its bookmark
jpush() {
    local bookmark
    bookmark=$(_jj-get-current-bookmark) || return

    echo "Pushing bookmark: $bookmark"
    jj git push --bookmark "$bookmark" "$@"
}

# Clean up empty commits with no description
jclean() {
    local scope="${1:-mutable()}"

    # Find empty commits with no description
    local -a empty_commits
    empty_commits=(${(f)"$(jj log -r "$scope & empty()" --no-graph -T 'if(description, "", change_id.short() ++ "\n")' 2>/dev/null)"})

    if [[ ${#empty_commits[@]} -eq 0 ]]; then
        echo "No empty commits without description found"
        return 0
    fi

    echo "Found ${#empty_commits[@]} empty commit(s) with no description:"
    for commit in "${empty_commits[@]}"; do
        echo "  $commit"
    done

    echo ""
    echo "Abandon these commits? [y/N]"
    read -q || return 0
    echo ""

    jj abandon "${empty_commits[@]}"
}

# Help function
jj-help() {
    cat << 'EOF'
Jujutsu Helper Module (git-branchless style)

Key Functions:
  jpr [options] [bookmark]      Create or update PR (-c to create, -d for draft, -a for all)
  jjsync [options] [bookmark]   Sync all local work with trunk() (-c current, -m mine, -b <base>)
  jmove [-s|-r] <commit> <dest> Move commits (-s with descendants, -r single commit)
  jpush [options]               Push current bookmark to remote
  jpush-main                    Set main bookmark and push
  jjst                          Status with recent log
  jjco                          Interactive bookmark checkout (requires fzf)
  jclean [scope]                Abandon empty commits with no description (default: mutable())

Common Aliases:
  jl, jsl, jlg      Log views          jb*, jbc, jbd     Bookmark operations
  jst, jdiff        Status/diff        je, jsq, jsqi     Edit/squash changes
  jrb*, jins, jinb  Rebase/insert      jprev, jnext      Navigate commits
  jundo, jredo      Undo/redo ops      jgf, jgp          Git fetch/push

Run 'jjhelp' to see this help. See README.md for detailed examples.
EOF
}

# Alias for help
alias jjhelp='jj-help'

# Source local customizations if they exist
[[ -f "${0:h}/local.zsh" ]] && source "${0:h}/local.zsh"

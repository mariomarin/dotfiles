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
alias jgf='jj git fetch'
alias jgp='jj git push'

#
# Helper Functions
#

_jj-get-current-bookmark() {
    local bookmark
    bookmark=$(jj log -r @ --no-graph -T 'bookmarks' 2>/dev/null)

    [[ -n "$bookmark" ]] || {
        echo "Error: No bookmark found for current change (@)" >&2
        echo "Create a bookmark first: jj bookmark create <name>" >&2
        return 1
    }

    echo "$bookmark"
}

_jj-get-all-bookmarks() {
    # Get local bookmarks only (not indented), strip trailing colon
    local -a lines
    lines=(${(f)"$(jj bookmark list)"})
    # Filter non-indented lines, extract first field, strip colon
    print -l ${${${(M)lines:#[^[:space:]]*}%% *}%:}
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

        local pr_exists
        pr_exists=$(command gh pr list --head "$bm" --json number --jq '.[0].number' 2>/dev/null)

        if [[ -n "$pr_exists" ]]; then
            echo "  PR #$pr_exists exists, updating..."
            jj git push --bookmark "$bm" --force || exit_code=$?
            continue
        fi

        [[ "$create" != true ]] && {
            echo "  No PR found. Use --create to create one." >&2
            exit_code=1
            continue
        }

        echo "  Creating new PR..."
        command gh pr create --head "$bm" --fill "${gh_args[@]}" || exit_code=$?
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

    # Choose revset based on --mine flag
    local revset
    if [[ "$mine_only" == true ]]; then
        revset="roots(${base_bookmark}..mine())"
    else
        revset="roots(${base_bookmark}..mutable())"
    fi

    # Single rebase operation for all local commit stacks
    if jj rebase -s "$revset" -d "$base_bookmark" 2>&1; then
        echo "✅ Sync complete"
        echo ""
        echo "📊 Current state:"
        jj log -r "${base_bookmark}..mutable()" --limit 10 2>/dev/null || jj log --limit 10
        return 0
    else
        echo "⚠️  Some commits have conflicts (deferred in graph)"
        echo ""
        echo "📊 Current state:"
        jj log -r "${base_bookmark}..mutable()" --limit 10 2>/dev/null || jj log --limit 10
        return 1
    fi
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

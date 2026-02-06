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

# Abandon (a)
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
    jj bookmark list | awk '{print $1}'
}

_jj-detect-default-branch() {
    local remote="${1:-origin}"
    local default_ref

    # Try git symbolic-ref first
    default_ref=$(git symbolic-ref "refs/remotes/${remote}/HEAD" 2>/dev/null | sed "s|refs/remotes/${remote}/||")
    [[ -n "$default_ref" ]] && {
        echo "${remote}/${default_ref}"
        return 0
    }

    # Fallback: try common default branches
    for candidate in "${remote}/main" "${remote}/master" "main" "master"; do
        jj log -r "$candidate" --limit 1 &>/dev/null && {
            echo "$candidate"
            return 0
        }
    done

    return 1
}

_jj-get-remote() {
    local remote
    remote=$(jj git remote list 2>/dev/null | head -1 | awk '{print $1}')
    echo "${remote:-origin}"
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
        pr_exists=$(gh pr list --head "$bm" --json number --jq '.[0].number' 2>/dev/null)

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
        gh pr create --head "$bm" --fill "${gh_args[@]}" || exit_code=$?
    done

    return $exit_code
}

# Sync with remote: fetch and rebase on default branch
jjsync() {
    local pull=true
    local all=false
    local bookmark=""
    local base_branch=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--pull) pull=true; shift ;;
            --no-pull) pull=false; shift ;;
            -a|--all) all=true; shift ;;
            -b|--base) base_branch="$2"; shift 2 ;;
            *) bookmark="$1"; shift ;;
        esac
    done

    if [[ "$pull" == true ]]; then
        echo "Fetching from remote..."
        jj git fetch || return
    fi

    if [[ -z "$base_branch" ]]; then
        local remote_bookmark
        remote_bookmark=$(jj log -r @ --no-graph -T 'bookmarks' 2>/dev/null)

        if [[ -n "$remote_bookmark" ]] && [[ "$remote_bookmark" != *"@"* ]]; then
            base_branch="${remote_bookmark}@origin"
        else
            local remote
            remote=$(_jj-get-remote)
            base_branch=$(_jj-detect-default-branch "$remote") || {
                echo "Error: Could not detect default branch" >&2
                return 1
            }
        fi
    fi

    echo "Base branch: $base_branch"

    if [[ "$all" == true ]]; then
        echo "Syncing all bookmarks..."
        local bookmarks
        bookmarks=($(_jj-get-all-bookmarks))

        local exit_code=0
        for bm in "${bookmarks[@]}"; do
            echo "  Syncing: $bm"
            jj rebase -b "$bm" -d "$base_branch" || exit_code=$?
        done
        return $exit_code
    fi

    if [[ -n "$bookmark" ]]; then
        echo "Syncing bookmark: $bookmark"
        jj rebase -b "$bookmark" -d "$base_branch"
        return
    fi

    echo "Syncing current change (@)"
    jj rebase -d "$base_branch"
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
    bookmark=$(jj bookmark list | fzf --height=20 --reverse | awk '{print $1}')
    [[ -n "$bookmark" ]] && jj new "$bookmark"
}

# Move commits (git-branchless style)
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

# Source local customizations if they exist
[[ -f "${0:h}/local.zsh" ]] && source "${0:h}/local.zsh"

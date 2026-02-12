# Jujutsu (jj) Helper Module for Zimfw
# Mirrors git module structure with jj-specific aliases and functions
# This is a Zsh module - no shebang needed as it's sourced, not executed

# Directory for module functions
JJ_HELPERS_DIR="${0:h}/functions"

# Create functions directory if it doesn't exist
[[ -d "$JJ_HELPERS_DIR" ]] || mkdir -p "$JJ_HELPERS_DIR"

# Add to fpath for autoloading
fpath=("$JJ_HELPERS_DIR" "${fpath[@]}")

# Only proceed if jj command exists
if (( ! ${+commands[jj]} )); then
    return 0
fi

#
# Aliases
# (sorted alphabetically by alias)
#

# Bookmark operations
alias jb='jj bookmark'
alias jbc='jj bookmark create'
alias jbd='jj bookmark delete'
alias jbl='jj bookmark list'
alias jbm='jj bookmark move'
alias jbset='jj bookmark set'
alias jbtrack='jj bookmark track'

# Change operations
alias jc='jj commit'
alias jd='jj describe'
alias jn='jj new'
alias je='jj edit'           # Edit old commit (like git checkout + amend)
alias jsq='jj squash'         # Squash into parent
alias jsqi='jj squash -i'     # Interactive squash
alias jsqf='jj squash --from' # Squash from another commit

# Diff and status
alias jdiff='jj diff'
alias jde='jj diffedit'       # Interactive diff editor
alias jst='jj status'

# Log (smartlog-style)
alias jl='jj log'
alias jlg='jj log --graph'
alias jsl='jj log -r "all()" --limit 20'  # Smartlog view

# Navigation (git prev/next equivalents)
alias jprev='jj prev'
alias jnext='jj next'

# Rebase operations
alias jrb='jj rebase'
alias jrbi='jj rebase -d'      # Rebase to destination
alias jrbs='jj rebase -s'      # Rebase source (commit + descendants)
alias jrbr='jj rebase -r'      # Rebase revisions (single commit)

# Insert operations
alias jins='jj new --insert-after'  # Insert new change after
alias jinb='jj new --insert-before' # Insert new change before

# Abandon/hide operations
alias jab='jj abandon'         # Abandon/hide commits
alias junhide='jj restore'     # Restore abandoned commits

# Operation log (undo/redo)
alias jop='jj op'
alias joplog='jj op log'
alias jundo='jj op undo'
alias jredo='jj op restore'

# Git operations
alias jgf='jj git fetch'
alias jgp='jj git push'

#
# Functions
#

# Create or update PR from jj bookmark(s)
# Usage: jpr [-c|--create] [-d|--draft] [-a|--all] [bookmark]
jpr() {
    local create=false
    local draft=false
    local all=false
    local bookmark=""
    local gh_args=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--create)
                create=true
                shift
                ;;
            -d|--draft)
                draft=true
                gh_args+=(--draft)
                shift
                ;;
            -a|--all)
                all=true
                shift
                ;;
            -*)
                # Pass other flags to gh
                gh_args+=("$1")
                shift
                ;;
            *)
                bookmark="$1"
                shift
                ;;
        esac
    done

    # Get bookmark(s) to process
    local bookmarks=()
    if [[ "$all" == true ]]; then
        # Get all bookmarks
        bookmarks=($(jj bookmark list | awk '{print $1}'))
    elif [[ -n "$bookmark" ]]; then
        bookmarks=("$bookmark")
    else
        # Get current bookmark
        local current
        current=$(jj log -r @ --no-graph -T 'bookmarks')
        if [[ -z "$current" ]]; then
            echo "Error: No bookmark found for current change (@)" >&2
            echo "Create a bookmark first: jj bookmark create <name>" >&2
            return 1
        fi
        bookmarks=("$current")
    fi

    # Process each bookmark
    local exit_code=0
    for bm in "${bookmarks[@]}"; do
        echo "Processing bookmark: $bm"

        # Check if PR already exists
        local pr_exists
        pr_exists=$(gh pr list --head "$bm" --json number --jq '.[0].number' 2>/dev/null)

        if [[ -n "$pr_exists" ]]; then
            # Update existing PR by pushing
            echo "  PR #$pr_exists exists, updating..."
            jj git push --bookmark "$bm" --force || exit_code=$?
        elif [[ "$create" == true ]]; then
            # Create new PR
            echo "  Creating new PR..."
            gh pr create --head "$bm" --fill "${gh_args[@]}" || exit_code=$?
        else
            echo "  No PR found. Use --create to create one." >&2
            exit_code=1
        fi
    done

    return $exit_code
}

# Sync with remote: fetch and rebase on default branch
# Usage: jjsync [-p|--pull] [-a|--all] [-b|--base <branch>] [bookmark]
jjsync() {
    local pull=true
    local all=false
    local bookmark=""
    local base_branch=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--pull|--no-pull)
                if [[ "$1" == "--no-pull" ]]; then
                    pull=false
                fi
                shift
                ;;
            -a|--all)
                all=true
                shift
                ;;
            -b|--base)
                base_branch="$2"
                shift 2
                ;;
            *)
                bookmark="$1"
                shift
                ;;
        esac
    done

    # Fetch if requested
    if [[ "$pull" == true ]]; then
        echo "Fetching from remote..."
        jj git fetch || return $?
    fi

    # Detect default branch if not specified
    if [[ -z "$base_branch" ]]; then
        # Try to get tracked remote bookmark for current change
        local remote_bookmark
        remote_bookmark=$(jj log -r @ --no-graph -T 'bookmarks' 2>/dev/null)

        # If no tracked bookmark, use the default remote branch
        if [[ -z "$remote_bookmark" ]] || [[ "$remote_bookmark" == *"@"* ]]; then
            # Get remote name (default to origin)
            local remote
            remote=$(jj git remote list 2>/dev/null | head -1 | awk '{print $1}')
            if [[ -z "$remote" ]]; then
                remote="origin"
            fi

            # Try to detect actual default branch from git remote HEAD
            local default_ref
            default_ref=$(git symbolic-ref "refs/remotes/${remote}/HEAD" 2>/dev/null | sed "s|refs/remotes/${remote}/||")

            if [[ -n "$default_ref" ]]; then
                # Use detected default branch
                base_branch="${remote}/${default_ref}"
            else
                # Fallback: try common default branches
                for candidate in "${remote}/main" "${remote}/master" "main" "master"; do
                    if jj log -r "$candidate" --limit 1 &>/dev/null; then
                        base_branch="$candidate"
                        break
                    fi
                done
            fi
        else
            # Use the remote tracking branch
            base_branch="${remote_bookmark}@origin"
        fi
    fi

    echo "Base branch: $base_branch"

    # Get bookmark(s) to sync
    if [[ "$all" == true ]]; then
        echo "Syncing all bookmarks..."
        local bookmarks
        bookmarks=($(jj bookmark list | awk '{print $1}'))

        local exit_code=0
        for bm in "${bookmarks[@]}"; do
            echo "  Syncing: $bm"
            jj rebase -b "$bm" -d "$base_branch" || exit_code=$?
        done
        return $exit_code
    elif [[ -n "$bookmark" ]]; then
        echo "Syncing bookmark: $bookmark"
        jj rebase -b "$bookmark" -d "$base_branch"
    else
        echo "Syncing current change (@)"
        jj rebase -d "$base_branch"
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
    if ! (( $+commands[fzf] )); then
        echo "Error: fzf is required for interactive bookmark selection" >&2
        return 1
    fi

    local bookmark
    bookmark=$(jj bookmark list | fzf --height=20 --reverse | awk '{print $1}')

    if [[ -n "$bookmark" ]]; then
        jj new "$bookmark"
    fi
}

# Move commits (git-branchless style)
# Usage: jmove [-s|-r] <commit> <dest>
# -s: move commit and descendants (source)
# -r: move single commit only (revisions)
jmove() {
    local mode="-s"  # default: source (with descendants)
    local commit=""
    local dest=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--source)
                mode="-s"
                shift
                ;;
            -r|-x|--exact)
                mode="-r"
                shift
                ;;
            *)
                if [[ -z "$commit" ]]; then
                    commit="$1"
                elif [[ -z "$dest" ]]; then
                    dest="$1"
                else
                    echo "Error: Too many arguments" >&2
                    echo "Usage: jmove [-s|-r] <commit> <dest>" >&2
                    return 1
                fi
                shift
                ;;
        esac
    done

    if [[ -z "$commit" ]] || [[ -z "$dest" ]]; then
        echo "Error: Missing required arguments" >&2
        echo "Usage: jmove [-s|-r] <commit> <dest>" >&2
        echo "  -s, --source: move commit and descendants (default)" >&2
        echo "  -r, -x, --exact: move single commit only" >&2
        return 1
    fi

    echo "Moving $commit (mode: $mode) to $dest"
    jj rebase "$mode" "$commit" -d "$dest"
}

# Push to main branch
jpush-main() {
    echo "Setting main bookmark to current change and pushing..."
    jj bookmark set main || return $?
    jj git push --bookmark main
}

# Push current change to its bookmark
jpush() {
    local current_bookmark
    current_bookmark=$(jj log -r @ --no-graph -T 'bookmarks')

    if [[ -z "$current_bookmark" ]]; then
        echo "Error: No bookmark found for current change (@)" >&2
        echo "Create a bookmark first: jj bookmark create <name>" >&2
        echo "Or push to main: jpush-main" >&2
        return 1
    fi

    echo "Pushing bookmark: $current_bookmark"
    jj git push --bookmark "$current_bookmark" "$@"
}

# Help function
jj_help() {
    echo "Jujutsu Helper Module (git-branchless style)"
    echo ""
    echo "=== Navigation ==="
    echo "  jprev       - Move to parent commit"
    echo "  jnext       - Move to child commit"
    echo ""
    echo "=== Viewing ==="
    echo "  jsl         - Smartlog view (last 20 commits)"
    echo "  jl          - Log view"
    echo "  jlg         - Log with graph"
    echo "  jst         - Status"
    echo "  jdiff       - Show diff"
    echo ""
    echo "=== Bookmarks ==="
    echo "  jb          - jj bookmark"
    echo "  jbc         - Create bookmark"
    echo "  jbd         - Delete bookmark"
    echo "  jbl         - List bookmarks"
    echo "  jbm         - Move bookmark"
    echo "  jbset       - Set bookmark to current change"
    echo "  jbtrack     - Track remote bookmark"
    echo ""
    echo "=== Editing ==="
    echo "  jn          - New change"
    echo "  je          - Edit old commit"
    echo "  jd          - Describe/reword commit"
    echo "  jsq         - Squash into parent"
    echo "  jsqi        - Interactive squash"
    echo "  jde         - Interactive diff editor"
    echo ""
    echo "=== Moving/Rebasing ==="
    echo "  jrb         - Rebase"
    echo "  jrbi        - Rebase to destination"
    echo "  jrbs        - Rebase source (commit + descendants)"
    echo "  jrbr        - Rebase single commit only"
    echo "  jins        - Insert new change after"
    echo "  jinb        - Insert new change before"
    echo ""
    echo "=== Hide/Abandon ==="
    echo "  jab         - Abandon/hide commits"
    echo "  junhide     - Restore abandoned commits"
    echo ""
    echo "=== Undo/Redo ==="
    echo "  jundo       - Undo last operation"
    echo "  jredo       - Redo operation"
    echo "  jop         - Operation commands"
    echo "  joplog      - Show operation log"
    echo ""
    echo "=== Git Operations ==="
    echo "  jgf         - Git fetch"
    echo "  jgp         - Git push"
    echo ""
    echo "=== Functions ==="
    echo "  jmove [-s|-r] <commit> <dest>"
    echo "      Move commits (git-branchless style)"
    echo "      -s: move commit + descendants (default)"
    echo "      -r/-x: move single commit only"
    echo ""
    echo "  jpr [options] [bookmark]"
    echo "      Create or update PR"
    echo "      -c: create if doesn't exist"
    echo "      -d: create as draft"
    echo "      -a: process all bookmarks"
    echo ""
    echo "  jjsync [options] [bookmark]"
    echo "      Fetch and rebase on default branch (auto-detected)"
    echo "      -p: fetch first (default)"
    echo "      --no-pull: skip fetch"
    echo "      -a: sync all bookmarks"
    echo "      -b <branch>: specify base branch (e.g., origin/master)"
    echo ""
    echo "  jpush       - Push current bookmark"
    echo "  jpush-main  - Set main to current and push"
    echo "  jjst        - Status with recent log"
    echo "  jjco        - Interactive bookmark checkout (fzf)"
}

# Alias for help
alias jjhelp='jj_help'

# Source local customizations if they exist
# shellcheck disable=SC1091
[[ -f "${0:h}/local.zsh" ]] && source "${0:h}/local.zsh"

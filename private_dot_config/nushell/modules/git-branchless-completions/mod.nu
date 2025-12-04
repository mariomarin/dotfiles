# git-branchless completions for Nushell

# Helper for color options
def _color_options [] {
    ["auto" "always" "never"]
}

# Main git-branchless command
export extern "git-branchless" [
    -C: string                        # Change to directory before executing
    --color: string@_color_options    # Force enable/disable colors
    --help(-h)                        # Display help information
    --version(-V)                     # Show version number
]

# amend - Amend the current HEAD commit
export extern "git branchless amend" [
    --help(-h)                        # Display help
]

# bug-report - Gather information for bug reports
export extern "git branchless bug-report" [
    --help(-h)                        # Display help
]

# difftool - Use partial commit selector as difftool
export extern "git branchless difftool" [
    --help(-h)                        # Display help
]

# gc - Run internal garbage collection
export extern "git branchless gc" [
    --help(-h)                        # Display help
]

# hide - Hide commits from smartlog
export extern "git branchless hide" [
    ...commits: string                # Commits to hide
    --help(-h)                        # Display help
]

# init - Initialize branchless workflow
export extern "git branchless init" [
    --help(-h)                        # Display help
]

# install-man-pages - Install man pages
export extern "git branchless install-man-pages" [
    path: string                      # Installation path
    --help(-h)                        # Display help
]

# move - Move subtree of commits
export extern "git branchless move" [
    --help(-h)                        # Display help
    --source(-s): string              # Source commit
    --dest(-d): string                # Destination commit
    --exact                           # Move exact commit range
    --insert                          # Insert commits
]

# next - Move to later commit in stack
export extern "git branchless next" [
    --help(-h)                        # Display help
    --newest(-n)                      # Move to newest descendant
    --oldest(-o)                      # Move to oldest descendant
    --interactive(-i)                 # Interactive mode
]

# prev - Move to earlier commit in stack
export extern "git branchless prev" [
    --help(-h)                        # Display help
    --newest(-n)                      # Move to newest ancestor
    --oldest(-o)                      # Move to oldest ancestor
    --interactive(-i)                 # Interactive mode
]

# query - Query commit graph using revset language
export extern "git branchless query" [
    query: string                     # Revset query
    --help(-h)                        # Display help
]

# repair - Restore internal invariants
export extern "git branchless repair" [
    --help(-h)                        # Display help
]

# restack - Fix abandoned commits
export extern "git branchless restack" [
    --help(-h)                        # Display help
]

# record - Create commit interactively
export extern "git branchless record" [
    --help(-h)                        # Display help
    --message(-m): string             # Commit message
    --interactive(-i)                 # Interactive mode
]

# reword - Reword commits
export extern "git branchless reword" [
    ...commits: string                # Commits to reword
    --help(-h)                        # Display help
    --message(-m): string             # New commit message
]

# smartlog - Display repository state visually
export extern "git branchless smartlog" [
    --help(-h)                        # Display help
]

# Alias: sl for smartlog
export extern "git sl" [
    --help(-h)                        # Display help
]

# submit - Push commits to remote
export extern "git branchless submit" [
    --help(-h)                        # Display help
    --create(-c)                      # Create pull request
    --draft(-d)                       # Create draft PR
]

# switch - Switch to branch or commit
export extern "git branchless switch" [
    target: string                    # Branch or commit to switch to
    --help(-h)                        # Display help
    --detach(-d)                      # Detach HEAD
]

# sync - Move local stacks on top of main branch
export extern "git branchless sync" [
    --help(-h)                        # Display help
    --pull                            # Pull from remote first
]

# test - Run command on commits
export extern "git branchless test" [
    --help(-h)                        # Display help
    --command(-c): string             # Command to run
    --exec(-x): string                # Execute command
]

# undo - Browse or return to previous state
export extern "git branchless undo" [
    --help(-h)                        # Display help
    --interactive(-i)                 # Interactive mode
]

# unhide - Unhide commits from smartlog
export extern "git branchless unhide" [
    ...commits: string                # Commits to unhide
    --help(-h)                        # Display help
]

# wrap - Wrap Git command in branchless transaction
export extern "git branchless wrap" [
    ...command: string                # Git command to wrap
    --help(-h)                        # Display help
]

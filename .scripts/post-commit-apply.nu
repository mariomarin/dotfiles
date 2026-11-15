#!/usr/bin/env nu
# Post-commit: apply dotfiles unless the commit only touched paths chezmoi never reads

# Repo paths that neither chezmoi nor its run_onchange scripts use
const UNAPPLIED = [
    '^docs/'
    '^memory/'
    '^updatecli/'
    '^\.github/'
    '^\.claude/'
    '^\.scripts/tests/'
    '^private_dot_local/bin/tests/'
    '^nix/.*/tests/'
    '^nix/.*\.md$'
    'CLAUDE\.md$'
    '^README\.md$'
    '^devenv\.(nix|lock|yaml)$'
    '^\.(editorconfig|gitignore|rumdl\.toml|stylua\.toml)$'
]

def is-applied [path: string]: nothing -> bool {
    $UNAPPLIED | all {|pattern| $path !~ $pattern }
}

# Files changed by HEAD, or null when there is no parent commit to diff against
def find-changed []: nothing -> any {
    let diff = do { git diff --name-only HEAD~1 HEAD } | complete
    if $diff.exit_code != 0 { return null }
    $diff.stdout | lines
}

def main [] {
    let changed = find-changed
    if $changed != null and ($changed | all {|path| not (is-applied $path) }) { return }
    just
}

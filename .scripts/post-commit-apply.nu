#!/usr/bin/env nu
# Post-commit: apply dotfiles unless the commit only touched paths chezmoi never reads

use adt.nu [run-cmd, "result map", "result unwrap-or"]

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

# Result of the files changed by HEAD; err when there is no parent commit to diff against
def changed-files []: nothing -> record {
    run-cmd { git diff --name-only HEAD~1 HEAD } | result map {|out| $out.stdout | lines }
}

def main [] {

    # nu-lint-ignore: missing_output_type
    let repo_only = changed-files
    | result map {|paths| $paths | all {|path| not (is-applied $path) } }
    | result unwrap-or false
    if $repo_only { return }
    just
}

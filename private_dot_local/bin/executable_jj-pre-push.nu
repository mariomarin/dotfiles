#!/usr/bin/env nu
# Pre-commit integration for jj git push
# Based on https://github.com/acarapetis/jj-pre-push

# Patterns for parsing bookmark updates
def bookmark-patterns [] {
    {
        move_forward: 'Move forward bookmark (\S+) from (\w+) to (\w+)',
        move_backward: 'Move backward bookmark (\S+) from (\w+) to (\w+)',
        move_sideways: 'Move sideways bookmark (\S+) from (\w+) to (\w+)',
        add: 'Add bookmark (\S+) to (\w+)',
        delete: 'Delete bookmark (\S+) from (\w+)'
    }
}

# Try to match line with a pattern type
def try-match-pattern [line: string, type: string, pattern: string] {
    let match = ($line | parse --regex $pattern)
    if ($match | is-empty) {
        null
    } else {
        $match | first | insert type $type
    }
}

# Convert match to bookmark update record
def match-to-update [match: record] {
    match $match.type {
        "add" => {
            remote: "",
            bookmark: $match.capture0,
            update_type: $match.type,
            old_commit: "",
            new_commit: $match.capture1
        },
        "delete" => {
            remote: "",
            bookmark: $match.capture0,
            update_type: $match.type,
            old_commit: $match.capture1,
            new_commit: ""
        },
        _ => {
            remote: "",
            bookmark: $match.capture0,
            update_type: $match.type,
            old_commit: $match.capture1,
            new_commit: $match.capture2
        }
    }
}

# Parse bookmark update line from jj git push --dry-run
def parse-bookmark-update [line: string] {
    let trimmed = ($line | str trim)
    let matches = (bookmark-patterns
        | transpose type pattern
        | each {|p| try-match-pattern $trimmed $p.type $p.pattern }
        | where {|x| $x != null })

    if ($matches | is-empty) {
        null
    } else {
        match-to-update ($matches | first)
    }
}

# Get workspace root
def workspace-root [] {
    ^jj workspace root | complete | get stdout | str trim
}

# Get current change info
def current-change [] {
    ^jj log --no-graph -r @ -T 'change_id.shortest(8) ++ "," ++ commit_id.shortest(12) ++ "," ++ empty'
    | complete
    | get stdout
    | str trim
    | split row ","
    | {
        change_id: ($in | get 0),
        commit_id: ($in | get 1),
        empty: (($in | get 2) == "true")
    }
}

# Check if pre-commit config exists
def has-pre-commit-config [] {
    [(workspace-root) ".pre-commit-config.yaml"] | path join | path exists
}

# Parse remote line
def parse-remote [line: string] {
    let match = ($line | parse --regex '^Changes to push to (.+?):')
    if ($match | is-empty) {
        null
    } else {
        $match | first | get capture0
    }
}

# Parse all bookmark updates from dry-run output
def parse-updates [output: string, remote: string] {
    $output
    | lines
    | reduce -f {remote: "", updates: []} {|line, acc|
        let new_remote = (parse-remote $line)
        if $new_remote != null {
            $acc | update remote $new_remote
        } else {
            let update = (parse-bookmark-update $line)
            if $update != null {
                $acc | update updates ($acc.updates | append ($update | update remote $acc.remote))
            } else {
                $acc
            }
        }
    }
    | get updates
}

# Get bookmark updates from jj git push --dry-run
def get-updates [...push_args: string] {
    let result = (^jj git push --dry-run ...$push_args | complete)

    if $result.exit_code != 0 {
        print $"Error: ($result.stderr)"
        []
    } else {
        parse-updates $result.stderr ""
    }
}

# Check if working copy has changes
def has-changes [] {
    ^jj diff -r @ --summary | complete | get stdout | str trim | is-not-empty
}

# Check commit messages using commitizen
def check-commit-messages [from_ref: string, to_ref: string] {
    let result = (do { ^cz check --rev-range $"($from_ref)..($to_ref)" } | complete)

    if $result.exit_code == 0 {
        print "  ✅ All commit messages valid"
        { success: true }
    } else {
        print "  ❌ Commit message validation failed:"
        print $result.stderr
        { success: false }
    }
}

# Run pre-commit check
def run-check [from_ref: string, to_ref: string] {
    print $"  Running pre-commit on ($from_ref | str substring 0..8)...($to_ref | str substring 0..8)"

    let msg_check = (check-commit-messages $from_ref $to_ref)
    if not $msg_check.success {
        return {
            success: false,
            changed: false,
            output: "Commit message validation failed"
        }
    }

    pre-commit run --hook-stage pre-push --from-ref $from_ref --to-ref $to_ref
    | complete
    | {
        success: ($in.exit_code == 0),
        changed: (has-changes),
        output: $in.stdout
    }
}

# Get remote heads for new bookmark
def remote-heads [new_commit: string, remote: string] {
    let revset = $"heads\(::($new_commit) & ::remote_bookmarks\(remote=exact:($remote)\)\)"
    ^jj log --no-graph -r $revset -T "commit_id"
    | lines
    | where {|x| $x != "" }
}

# Determine from refs for bookmark update
def from-refs [update: record] {
    if $update.old_commit != "" {
        [$update.old_commit]
    } else {
        let heads = (remote-heads $update.new_commit $update.remote)
        if ($heads | is-empty) { [$update.new_commit] } else { $heads }
    }
}

# Check single ref range
def check-range [from_ref: string, to_ref: string] {
    ^jj new $to_ref --quiet
    run-check $from_ref $to_ref
}

# Report check result
def report-result [update: record, result: record] {
    if not $result.success {
        let current = (current-change)
        if $result.changed {
            print $"❌ ($update.bookmark): pre-commit changed files, see change ($current.change_id)"
        } else {
            print $"❌ ($update.bookmark): pre-commit failed but changed no files"
        }
        false
    } else {
        print $"✅ ($update.bookmark): pre-commit passed"
        true
    }
}

# Check single bookmark update
def check-update [update: record] {
    print $"🔍 Checking ($update.bookmark)..."

    from-refs $update
    | each {|from_ref| check-range $from_ref $update.new_commit }
    | each {|result| report-result $update $result }
    | all {|x| $x }
}

# Clean up any stale temporary bookmarks from previous runs
def cleanup-stale-bookmarks [] {
    let stale = (^jj bookmark list | lines | parse "{name}:" | where name =~ "jj-pre-push-keep-" | get name)
    if ($stale | is-not-empty) {
        $stale | each {|b| ^jj bookmark forget $b --quiet }
    }
}

# Create temporary bookmark
def create-temp-bookmark [] {
    cleanup-stale-bookmarks
    let name = $"jj-pre-push-keep-(random chars -l 10)"
    ^jj bookmark create $name -r @ --quiet
    $name
}

# Cleanup temporary bookmark
def cleanup-temp-bookmark [name: string] {
    ^jj edit $name --quiet
    ^jj bookmark forget $name --quiet
}

# Print update summary
def print-updates [updates: list] {
    let count = ($updates | length)
    print $"📋 Will check ($count) bookmark\(s\)"
    $updates | each {|u| print $"  - ($u.bookmark): ($u.update_type)" }
    print ""
}

# Check all updates with temporary bookmark
def check-all-updates [updates: list] {
    let temp = (create-temp-bookmark)

    let results = try {
        $updates | each {|u| check-update $u }
    } catch {|e|
        cleanup-temp-bookmark $temp
        print $"Error during pre-commit checks: ($e)"
        error make {msg: $e}
    }

    cleanup-temp-bookmark $temp
    $results
}

# Report final result
def report-final [all_passed: bool] {
    print ""
    if $all_passed {
        print "✅ All checks passed"
    } else {
        print "❌ One or more checks failed, please fix before pushing"
        exit 1
    }
}

# Validate updates exist
def validate-updates [updates: list] {
    if ($updates | is-empty) {
        print "No bookmarks to push, nothing to check"
        null
    } else {
        $updates
    }
}

# Filter non-deletions
def non-deletions [updates: list] {
    let filtered = ($updates | where update_type != "delete")
    if ($filtered | is-empty) {
        print "Only deletions to push, nothing to check"
        null
    } else {
        $filtered
    }
}

# Main check pipeline
def check-pipeline [...push_args: string] {
    if not (has-pre-commit-config) {
        print "No .pre-commit-config.yaml found in workspace root"
        print "Run 'direnv allow' to generate from devenv.nix"
        return
    }

    print "📦 Checking what would be pushed..."

    let updates = (validate-updates (get-updates ...$push_args))
    if $updates == null { return }

    let filtered = (non-deletions $updates)
    if $filtered == null { return }

    print-updates $filtered

    let all_passed = (check-all-updates $filtered | all {|x| $x })
    report-final $all_passed
}

# Main pre-push command
def "main check" [
    ...push_args: string  # Arguments to pass to jj git push
] {
    check-pipeline ...$push_args
}

# Push with pre-commit checks
def "main push" [
    --dry-run  # Don't actually push, just check
    ...push_args: string  # Arguments to pass to jj git push
] {
    check-pipeline ...$push_args

    if $dry_run {
        print "Dry run, not pushing"
        return
    }

    print ""
    print "🚀 Running jj git push..."
    ^jj git push ...$push_args
}

# Show help
def "main help" [] {
    print "jj-pre-push: Pre-commit integration for jj"
    print "============================================"
    print ""
    print "Usage: jj-pre-push.nu <command> [args...]"
    print ""
    print "Commands:"
    print "  check [push-args]  Check what would be pushed with pre-commit"
    print "  push [push-args]   Check and push if all pass"
    print "  help               Show this help"
    print ""
    print "Validation includes:"
    print "  - Commitizen (conventional commits, 50 char limit)"
    print "  - All pre-commit hooks from devenv.nix"
    print ""
    print "Examples:"
    print "  jj-pre-push.nu check"
    print "  jj-pre-push.nu push"
    print "  jj-pre-push.nu push --branch main"
    print ""
    print "jj aliases:"
    print "  jj pre-check       Run pre-commit checks"
    print "  jj push-check      Check and push"
}

def main [] {
    main help
}

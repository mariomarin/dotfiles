#!/usr/bin/env nu
# Update vendored agent skills listed in .claude/skills/skills-lock.json.
# Prints one compare URL per updated skill (for the PR body); silent otherwise.

use adt.nu [ok, err, run-cmd, "result flat-map", "result map"]

def --wrapped git-in [dir: string, ...args: string]: nothing -> record {
    run-cmd { ^git -C $dir ...$args }
    | result map {|out| $out.stdout | str trim }
}

# Sparse, shallow fetch of the default branch head into a temp dir
def fetch-head [url: string, path: string]: nothing -> record {
    let dir = (mktemp -d)
    let result = (git-in $dir init -q
        | result flat-map {|_| git-in $dir sparse-checkout set --cone $path }
        | result flat-map {|_| git-in $dir fetch -q --depth 1 --filter=blob:none $url HEAD }
        | result flat-map {|_| git-in $dir rev-parse FETCH_HEAD }
        | result map {|rev| {dir: $dir, rev: $rev} })
    if not $result.ok { rm -rf $dir }
    $result
}

def checkout [dir: string, path: string]: nothing -> record {
    git-in $dir checkout -q FETCH_HEAD
    | result flat-map {|_|
        if ($dir | path join $path | path exists) { ok $dir } else { err {stderr: $"($path) not found upstream"} }
    }
}

def replace-skill [dest: string, src: string, path: string]: nothing -> nothing {
    rm -rf $dest
    cp -r ($src | path join $path) $dest
    cp ($src | path join LICENSE) ($dest | path join LICENSE)
}

def update-skill [
    name: string
    entry: record
    skills_dir: string
    base: string
]: nothing -> record {
    if $name !~ '^[A-Za-z0-9_-]+$' { return (err $"($name): invalid skill name") }
    let fetched = (fetch-head $"($base)/($entry.repo)" $entry.path)
    if not $fetched.ok { return (err $"($name): ($fetched.error.stderr | str trim)") }
    let head = $fetched.value
    if $head.rev == $entry.rev {
        rm -rf $head.dir
        return (ok null)
    }
    let result = (checkout $head.dir $entry.path
        | result map {|src| replace-skill ($skills_dir | path join $name) $src $entry.path }
        | result map {|_| {name: $name, old: $entry.rev, new: $head.rev, repo: $entry.repo} })
    rm -rf $head.dir
    if $result.ok { $result } else { err $"($name): ($result.error.stderr | str trim)" }
}

# Write updated revs back to the lock and print one compare URL per update
def record-updates [lock: path, entries: record, updates: list<any>]: nothing -> nothing {
    $updates
    | reduce --fold $entries {|u, acc| $acc | upsert ([$u.name rev] | into cell-path) $u.new }
    | to json --indent 2
    | $"($in)\n"
    | save --force $lock
    for u in $updates {
        print $"- ($u.name): https://github.com/($u.repo)/compare/($u.old)...($u.new)"
    }
}

# Update each skill in the lock to its upstream default-branch head
def main [
    --lock: path = ".claude/skills/skills-lock.json" # Lock file; skills live next to it
    --base: string = "https://github.com" # Remote prefix, overridable for tests
]: nothing -> nothing {
    let skills_dir = $lock | path dirname
    let entries = open $lock
    let results = $entries | items {|name, entry| update-skill $name $entry $skills_dir $base }
    let updates = $results | where ok | get value | compact
    if ($updates | is-not-empty) { record-updates $lock $entries $updates }

    let failures = $results | where not ok | get error
    if ($failures | is-empty) { return }
    for f in $failures { print -e $"✗ ($f)" }
    exit 1
}

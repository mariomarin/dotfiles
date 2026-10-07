#!/usr/bin/env nu

# Krew plugin management script

use adt.nu [ok, err, run-cmd]

def main [] {
    main sync
}

def krewfile []: nothing -> string {
    $nu.home-dir | path join ".krewfile"
}

def ensure-krew [] {
    if (which krew | is-not-empty) { return }
    error make {msg: "krew not found — install via nix"}
}

def parse-krewfile [content: string]: nothing -> list<string> {
    $content
    | lines
    | str trim
    | where {|it| not ($it | is-empty) }
    | where {|it| not ($it | str starts-with "#") }
    | where {|it| not ($it | str starts-with "index") }
}

def load-krewfile []: nothing -> list<string> {
    let file = (krewfile)
    if not ($file | path exists) {
        error make {msg: $"Krewfile not found at ($file)"}
    }
    parse-krewfile (open $file)
}

def install-plugin [plugin: string]: nothing -> record {
    match (run-cmd { ^krew install $plugin }) {
        {ok: true} => (ok $plugin)
        {error: $failure} => (err $"($plugin): ($failure.stderr | str trim)")
    }
}

# Sync plugins from Krewfile; exits 1 if any fail so topgrade notices
def "main sync" [] {
    ensure-krew
    let failures = (load-krewfile
        | each {|plugin| install-plugin $plugin }
        | where {|r| not $r.ok }
        | get -o error)
    if ($failures | is-empty) { return }
    $failures | each {|f| print -e $"✗ ($f)" } | ignore
    exit 1
}

# List installed krew plugins
def "main list" [] {
    krew list
}

# Install a plugin and add it to the Krewfile (once)
def "main install" [plugin: string] {
    match (install-plugin $plugin) {
        {ok: true} => null
        {error: $e} => (error make {msg: $"Failed to install ($e)"})
    }
    let file = (krewfile)
    let listed = if ($file | path exists) { parse-krewfile (open $file) } else { [] }
    if $plugin in $listed { return }
    $"($plugin)\n" | save --append $file
}

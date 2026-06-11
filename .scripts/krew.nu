#!/usr/bin/env nu

# Krew plugin management script

def main [] {
    main sync
}

def ensure-krew [] {
    if (which kubectl-krew | is-not-empty) { return }
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
    let krewfile = $"($nu.home-dir)/.krewfile"
    if not ($krewfile | path exists) {
        error make {msg: $"Krewfile not found at ($krewfile)"}
    }
    parse-krewfile (open $krewfile)
}

# Sync plugins from Krewfile
def "main sync" [] {
    ensure-krew
    let plugins = load-krewfile

    $plugins | each {|plugin|
        let result = (do { kubectl krew install $plugin } | complete)
        if $result.exit_code != 0 {
            print -e $"✗ ($plugin): ($result.stderr)"
        }
    }
    | ignore
}

# List installed krew plugins
def "main list" [] {
    kubectl krew list
}

# Install a plugin and add to Krewfile
def "main install" [plugin: string] {
    let result = (do { kubectl krew install $plugin } | complete)
    if $result.exit_code != 0 {
        error make {msg: $"Failed to install ($plugin): ($result.stderr)"}
    }

    let krewfile = $"($nu.home-dir)/.krewfile"
    $"($plugin)\n" | save --append $krewfile
}

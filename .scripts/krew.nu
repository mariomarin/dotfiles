#!/usr/bin/env nu

# Krew plugin management script

def main [] {
    main sync
}

# Check if krew is bootstrapped, bootstrap if needed
def ensure-krew [] {
    let krew_bin = $"($env.HOME)/.local/share/krew/bin/kubectl-krew"
    if ($krew_bin | path exists) { return }

    let install_script = $"(mktemp -d)/install_krew.sh"
    let download = do {
        ^curl -fsSL https://krew.sigs.k8s.io/install | save -f $install_script
    } | complete

    if $download.exit_code != 0 {
        error make {msg: $"Failed to download krew installer: ($download.stderr)"}
    }

    let result = do { bash $install_script } | complete
    if $result.exit_code != 0 {
        error make {msg: $"Failed to bootstrap krew: ($result.stderr)"}
    }
}

# Parse plugins from Krewfile
def load-krewfile []: nothing -> list<string> {
    let krewfile = $"($nu.home-dir)/.krewfile"
    if not ($krewfile | path exists) {
        error make {msg: $"Krewfile not found at ($krewfile)"}
    }

    open $krewfile
    | lines
    | where $it !~ '^#' and $it !~ '^$' and $it !~ '^index'
    | str trim
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

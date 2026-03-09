#!/usr/bin/env nu

# Krew plugin management script

def main [] {
    print "Usage: nu krew.nu [sync|list|install]"
}

# Check if krew is bootstrapped, bootstrap if needed
def ensure-krew [] {
    let krew_bin = $"($env.HOME)/.local/share/krew/bin/kubectl-krew"
    if ($krew_bin | path exists) {
        return
    }

    print "🔧 Bootstrapping krew..."

    # Download and run the official krew installer
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

    print "✅ Krew bootstrapped successfully"
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
    print "🔄 Syncing krew plugins from ~/.krewfile..."

    ensure-krew

    let plugins = load-krewfile
    print $"📦 Found ($plugins | length) plugins in Krewfile"

    $plugins | each {|plugin|
        print $"  Installing ($plugin)..."
        kubectl krew install $plugin
    }

    print "✅ Krew plugins synced"
}

# List installed krew plugins
def "main list" [] {
    kubectl krew list
}

# Install a plugin and add to Krewfile
def "main install" [plugin: string] {
    print $"📦 Installing ($plugin)..."
    kubectl krew install $plugin

    let krewfile = $"($nu.home-dir)/.krewfile"
    print $"📝 Adding ($plugin) to ($krewfile)..."
    $"($plugin)\n" | save --append $krewfile

    print "✅ Done"
}

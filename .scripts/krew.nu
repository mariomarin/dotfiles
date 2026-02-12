#!/usr/bin/env nu

# Krew plugin management script

def main [] {
    print "Usage: nu krew.nu [sync|list|install]"
}

# Sync plugins from Krewfile
def "main sync" [] {
    print "🔄 Syncing krew plugins from ~/.krewfile..."

    # Check if krew is bootstrapped (exists in $KREW_ROOT/bin)
    let krew_bin = $"($env.HOME)/.local/share/krew/bin/kubectl-krew"
    if not ($krew_bin | path exists) {
        print "🔧 Bootstrapping krew..."
        let result = (do { kubectl krew install krew } | complete)
        if $result.exit_code != 0 {
            print $"❌ Failed to bootstrap krew: ($result.stderr)"
            return
        }
        print "✅ Krew bootstrapped successfully"
    }

    let krewfile = $"($nu.home-path)/.krewfile"
    if not ($krewfile | path exists) {
        print $"❌ Krewfile not found at ($krewfile)"
        return
    }

    # Parse plugins from Krewfile (ignore comments and empty lines)
    let plugins = (
        open $krewfile
        | lines
        | where $it !~ '^#' and $it !~ '^$' and $it !~ '^index'
        | str trim
    )

    print $"📦 Found ($plugins | length) plugins in Krewfile"

    # Install each plugin
    for plugin in $plugins {
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

    let krewfile = $"($nu.home-path)/.krewfile"
    print $"📝 Adding ($plugin) to ($krewfile)..."
    $plugin | save --append $krewfile

    print "✅ Done"
}

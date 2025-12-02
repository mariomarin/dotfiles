#!/usr/bin/env nu

# Krew plugin management script

def main [] {
    print "Usage: nu krew.nu [sync|list|install]"
}

# Sync plugins from Krewfile
def "main sync" [] {
    print "🔄 Syncing krew plugins from ~/.krewfile..."

    if (which krew | is-empty) {
        print "❌ krew not found. Install with: kubectl krew install krew"
        return
    }

    let krewfile = $"($env.HOME)/.krewfile"
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
        krew install $plugin
    }

    print "✅ Krew plugins synced"
}

# List installed krew plugins
def "main list" [] {
    krew list
}

# Install a plugin and add to Krewfile
def "main install" [plugin: string] {
    print $"📦 Installing ($plugin)..."
    krew install $plugin

    let krewfile = $"($env.HOME)/.krewfile"
    print $"📝 Adding ($plugin) to ($krewfile)..."
    $plugin | save --append $krewfile

    print "✅ Done"
}

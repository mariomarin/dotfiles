#!/usr/bin/env nu
# Install nushell plugins via nupm registry
# This script runs when this file changes

let nupm_path = ($nu.home-path | path join '.local' 'share' 'nupm' 'nupm')

# Check if nupm is installed
if not ($nupm_path | path exists) {
    print "⚠️  nupm not found. Skipping plugin installation."
    exit 0
}

print "🔌 Installing Nushell plugins via nupm registry..."

# List of plugins to install from nupm registry
let registry_plugins = [
    "nu_plugin_clipboard"
]

for plugin in $registry_plugins {
    print $"  Installing ($plugin)..."
    try {
        ^nu -c $"use ($nupm_path); nupm install ($plugin)"
        print $"  ✓ ($plugin) installed from registry"
    } catch {
        print $"  ⚠️  Failed to install ($plugin)"
    }
}

print ""
print "✅ Plugin installation complete"
print "   Run 'plugin list' to see registered plugins"

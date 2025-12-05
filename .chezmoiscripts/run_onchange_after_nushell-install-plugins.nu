#!/usr/bin/env nu
# Install nushell plugins via nupm
# This script runs when this file changes

let nupm_path = ($nu.home-path | path join '.local' 'share' 'nupm' 'nupm')
let plugins_dir = ($nu.home-path | path join '.local' 'share' 'nushell' 'plugins')

# Check if nupm is installed
if not ($nupm_path | path exists) {
    print "⚠️  nupm not found. Skipping plugin installation."
    exit 0
}

print "🔌 Installing Nushell plugins via nupm..."

# Create plugins directory if it doesn't exist
mkdir $plugins_dir

# List of plugins to install from GitHub via nupm
let github_plugins = [
    {
        name: "nu_plugin_clipboard"
        repo: "https://github.com/FMotalleb/nu_plugin_clipboard.git"
        description: "Clipboard integration (copy/paste)"
    }
]

for plugin in $github_plugins {
    print $"  Installing ($plugin.name) - ($plugin.description)..."
    let plugin_path = ($plugins_dir | path join $plugin.name)

    # Clone if not exists, otherwise pull
    if not ($plugin_path | path exists) {
        try {
            git clone $plugin.repo $plugin_path
        } catch {
            print $"  ⚠️  Failed to clone ($plugin.name)"
            continue
        }
    } else {
        try {
            cd $plugin_path
            git pull
            cd -
        } catch {
            print $"  ⚠️  Failed to update ($plugin.name)"
        }
    }

    # Install via nupm
    try {
        ^nu -c $"use ($nupm_path); nupm install --path ($plugin_path) -f"
        print $"  ✓ ($plugin.name) installed"
    } catch {
        print $"  ⚠️  Failed to install ($plugin.name) via nupm"
    }
}

print ""
print "✅ Plugin installation complete"
print "   Plugins will be registered when you start nushell"

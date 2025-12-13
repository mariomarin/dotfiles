#!/usr/bin/env nu
# Install nushell plugins via nupm registry (Windows only)
# NixOS/Darwin get plugins from nixpkgs (nushellPlugins.*)
# Plugins list: ~/.config/nushell/plugins.nuon

let nupm_path = ($nu.home-path | path join '.local' 'share' 'nupm' 'nupm')
let plugins_file = ($nu.home-path | path join '.config' 'nushell' 'plugins.nuon')

# Check if nupm is installed
if not ($nupm_path | path exists) {
    print "⚠️  nupm not found. Skipping plugin installation."
    exit 0
}

# Check if plugins file exists
if not ($plugins_file | path exists) {
    print $"⚠️  Plugins file not found at ($plugins_file)"
    exit 0
}

print "🔌 Installing Nushell plugins via nupm registry..."

let plugins = open $plugins_file

for plugin in $plugins {
    print $"  Installing ($plugin)..."
    let result = do { ^nu -c $"use ($nupm_path); nupm install ($plugin)" } | complete
    if $result.exit_code == 0 {
        print $"  ✓ ($plugin) installed"
    } else {
        print $"  ⚠️  Failed to install ($plugin)"
    }
}

print ""
print "✅ Plugin installation complete"
print "   Run 'plugin list' to see registered plugins"

#!/usr/bin/env nu
# Install all nupm modules
# This script runs when this file changes

let modules_dir = ($nu.home-path | path join '.config' 'nushell' 'modules')
let nupm_path = ($nu.home-path | path join '.local' 'share' 'nupm' 'nupm')

# Check if nupm is installed
if not ($nupm_path | path exists) {
    print "⚠️  nupm not found. Skipping module installation."
    exit 0
}

print "📦 Installing Nushell packages via nupm..."

# Install from nupm registry
print "  Installing nu-scripts (git, docker, kubernetes utilities)..."
try {
    ^nu -c $"use ($nupm_path); nupm install nu-scripts"
    print "  ✓ nu-scripts installed"
} catch {
    print "  ⚠️  Failed to install nu-scripts from registry"
}

# Install local custom modules
let local_modules = [
    "bitwarden"
    "claude-helpers"
    "sesh"
]

for module in $local_modules {
    let module_path = ($modules_dir | path join $module)

    if ($module_path | path exists) {
        print $"  Installing ($module)..."
        try {
            ^nu -c $"use ($nupm_path); nupm install --path ($module_path) --force"
            print $"  ✓ ($module) installed"
        } catch {
            print $"  ⚠️  Failed to install ($module)"
        }
    } else {
        print $"  ⚠️  Module not found: ($module_path)"
    }
}

print ""
print "✅ All modules installed successfully"
print "   Modules are now available for use with: use <module-name>"

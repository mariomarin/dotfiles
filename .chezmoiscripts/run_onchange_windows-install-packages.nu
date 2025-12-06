#!/usr/bin/env nu
# Install packages from winget configuration DSC file (Windows)
# This script runs when the winget configuration file or script content changes

print "📦 Installing packages for Windows using winget configure..."

# Check if winget is installed
if (which winget | is-empty) {
    print "❌ winget not found. Please install App Installer from Microsoft Store."
    exit 1
}

# Apply winget configuration
let config_file = ($nu.home-path | path join '.config' 'winget' 'configuration.dsc.yaml')
if not ($config_file | path exists) {
    print $"❌ Configuration file not found: ($config_file)"
    exit 1
}

print $"  Using configuration: ($config_file)"
winget configure --file $config_file --accept-configuration-agreements

if $env.LAST_EXIT_CODE == 0 {
    print "✅ Packages installed successfully"
} else {
    print "❌ Failed to install packages"
    exit 1
}

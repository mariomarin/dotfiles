#!/usr/bin/env nu
# nix-darwin management utilities

# First-time nix-darwin setup
def "main first-time" [
    host: string  # Hostname for the darwin configuration
] {
    print "🚀 First-time nix-darwin setup..."
    print "  This will install nix-darwin and apply the configuration"
    print ""
    print "⚠️  Note: This assumes Nix is already installed via Determinate Systems installer"
    print ""
    print "📦 Installing nix-darwin..."
    # Run darwin-rebuild from nix-darwin flake (uses master/unstable)
    let flake_ref = "nix-darwin/master#darwin-rebuild"
    let config_ref = $".#($host)"
    ^sudo ^nix run $flake_ref -- switch --flake $config_ref
    print ""
    print "✅ nix-darwin installed!"
    print "💡 Future rebuilds: just darwin"
}

# Show available darwin configurations
def "main hosts" [
    host: string  # Current hostname
] {
    print "Available nix-darwin configurations:"
    print $"  - ($host) : This Mac (detected via scutil)"
    print ""
    print $"Current HOST: ($host)"
    print ""
    print "To build for a different host:"
    print "  just switch HOST=other-hostname"
}

# Health check for nix-darwin system
def "main health" [] {
    print "🔍 nix-darwin Health Check"
    print "=========================="
    let hostname_result = (do { ^scutil --get LocalHostName } | complete)
    let hostname = if $hostname_result.exit_code == 0 { $hostname_result.stdout | str trim } else { "unknown" }
    print $"✓ Hostname: ($hostname)"
    let macos_result = (do { ^sw_vers -productVersion } | complete)
    let macos = if $macos_result.exit_code == 0 { $macos_result.stdout | str trim } else { "unknown" }
    print $"✓ macOS version: ($macos)"
    let arch_result = (do { ^uname -m } | complete)
    let arch = if $arch_result.exit_code == 0 { $arch_result.stdout | str trim } else { "unknown" }
    print $"✓ Architecture: ($arch)"
    let nix_result = (do { ^nix --version } | complete)
    let nix_version = if $nix_result.exit_code == 0 { $nix_result.stdout | str trim } else { "not installed" }
    print $"✓ Nix version: ($nix_version)"
    let darwin_rebuild_exists = (which darwin-rebuild | is-not-empty)
    print $"✓ darwin-rebuild: (if $darwin_rebuild_exists { 'installed' } else { '❌ not installed' })"
    let flake_path = "flake.nix"
    let flake_exists = ($flake_path | path exists)
    print $"✓ Flake exists: (if $flake_exists { 'yes' } else { '❌ no' })"
    let config_dir = ("/etc/nix-darwin" | path exists)
    print $"✓ nix-darwin config: (if $config_dir { 'installed' } else { 'not installed (run: just first-time)' })"
    print ""
}

# Show help
def "main help" [] {
    print "nix-darwin Utilities"
    print "===================="
    print ""
    print "Usage: nu darwin.nu <command> [args]"
    print ""
    print "Commands:"
    print "  first-time <host>   First-time nix-darwin setup"
    print "  hosts <host>        Show available configurations"
    print "  health              System health check"
    print "  help                Show this help message"
}

def main [] {
    main help
}

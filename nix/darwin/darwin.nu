#!/usr/bin/env nu
# nix-darwin management utilities

use ../../.scripts/nix-common.nu

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
    # Note: Use 'sudo env PATH=$env.PATH' to preserve PATH so sudo can find nix
    let flake_ref = "nix-darwin/master#darwin-rebuild"
    let config_ref = $".#($host)"
    sudo env $"PATH=($env.PATH)" nix run $flake_ref -- switch --flake $config_ref
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
    nix-common print-header "🔍 nix-darwin Health Check"

    nix-common health-item "Hostname" (nix-common run-or-default { scutil --get LocalHostName } "unknown")
    nix-common health-item "macOS version" (nix-common run-or-default { sw_vers -productVersion } "unknown")
    nix-common health-item "Architecture" (nix-common run-or-default { uname -m } "unknown")
    nix-common health-item "Nix version" (nix-common run-or-default { nix --version } "not installed")

    let darwin_rebuild_exists = (which darwin-rebuild | is-not-empty)
    nix-common health-item "darwin-rebuild" (if $darwin_rebuild_exists { "installed" } else { "❌ not installed" })

    let flake_exists = ("flake.nix" | path exists)
    nix-common health-item "Flake exists" (if $flake_exists { "yes" } else { "❌ no" })

    let config_dir = ("/etc/nix-darwin" | path exists)
    nix-common health-item "nix-darwin config" (if $config_dir { "installed" } else { "not installed (run: just first-time)" })

    print ""
}

# Show help
def "main help" [] {
    nix-common show-help "nix-darwin Utilities" "darwin.nu" [
        {name: "first-time <host>", description: "First-time nix-darwin setup"}
        {name: "hosts <host>", description: "Show available configurations"}
        {name: "health", description: "System health check"}
        {name: "help", description: "Show this help message"}
    ]
}

def main [] {
    main help
}

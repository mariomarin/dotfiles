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
    # Note: Use absolute path to nix to avoid PATH length issues with nested nix-shells
    # Note: Point to ../nixos for actual flake location (symlinks don't work with flake.lock)
    let flake_ref = "nix-darwin/master#darwin-rebuild"
    let config_ref = $"../nixos#($host)"
    sudo /nix/var/nix/profiles/default/bin/nix run $flake_ref -- switch --flake $config_ref
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

    nix-common health-item "Hostname" (do -i { ^scutil --get LocalHostName } | complete | get stdout | str trim)
    nix-common health-item "macOS version" (do -i { ^sw_vers -productVersion } | complete | get stdout | str trim)
    nix-common health-item "Architecture" (do -i { ^uname -m } | complete | get stdout | str trim)

    let nix_version = (do -i { nix --version } | complete)
    nix-common health-item "Nix version" (if $nix_version.exit_code == 0 { $nix_version.stdout | str trim } else { "not installed" })

    nix-common health-item "darwin-rebuild" (if (which darwin-rebuild | is-not-empty) { "installed" } else { "❌ not installed" })
    nix-common health-item "Flake exists" (if ("../nixos/flake.nix" | path exists) { "yes" } else { "❌ no" })
    nix-common health-item "nix-darwin config" (if ("/etc/nix-darwin" | path exists) { "installed" } else { "not installed (run: just first-time)" })

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

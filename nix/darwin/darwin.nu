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
def "main doctor" [] {
    mut issues = []

    let nix = (do -i { ^nix --version } | complete)
    if $nix.exit_code != 0 { $issues = ($issues | append "nix not installed — run: curl -L https://install.determinate.systems/nix | sh") }

    if (which darwin-rebuild | is-empty) { $issues = ($issues | append "darwin-rebuild missing — run: just first-time") }

    if not ("../nixos/flake.nix" | path exists) { $issues = ($issues | append "flake.nix missing") }

    if ($issues | is-empty) { return }
    print "darwin:"
    $issues | each {|i| print $"  ($i)" } | ignore
    exit 1
}

# Show help
def "main help" [] {
    nix-common show-help "nix-darwin Utilities" "darwin.nu" [
        {name: "first-time <host>", description: "First-time nix-darwin setup"}
        {name: "hosts <host>", description: "Show available configurations"}
        {name: "doctor", description: "Report problems with fixes"}
        {name: "help", description: "Show this help message"}
    ]
}

def main [] {
    main help
}

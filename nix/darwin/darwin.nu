#!/usr/bin/env nu
# nix-darwin management utilities

use ../../.scripts/nix-common.nu
use ../../.scripts/adt.nu [collect-issues]

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
    let issues = null | collect-issues [
        {|| check-nix }
        {|| check-darwin-rebuild }
        {|| check-flake }
        {|| check-lock }
    ]
    if ($issues | is-empty) { return }
    print "darwin:"
    for issue in $issues { print $"  ($issue)" }
    exit 1
}

def check-nix []: nothing -> any {
    let nix = do -i { ^nix --version } | complete
    if $nix.exit_code == 0 { return null }
    "nix not installed — run: curl -L https://install.determinate.systems/nix | sh"
}

def check-darwin-rebuild []: nothing -> any {
    if (which darwin-rebuild | is-not-empty) { return null }
    "darwin-rebuild missing — run: just first-time"
}

def check-flake []: nothing -> any {
    if ("../nixos/flake.nix" | path exists) { return null }
    "flake.nix missing"
}

def check-lock []: nothing -> any {
    let lock = "../nixos/flake.lock"
    if not ($lock | path exists) {
        return "flake.lock missing — run: cd ../nixos && nix flake update"
    }
    let modified = ls -l $lock | get 0.modified
    let age = (date now) - $modified
    if $age <= 30day { return null }
    $"flake.lock is ($age // 1day) days old — run: cd ../nixos && nix flake update"
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

#!/usr/bin/env nu
# NixOS management utilities

use ../../.scripts/nix-common.nu
use ../../.scripts/adt.nu [run-cmd collect-issues]

# OS compatibility check
def check-os [] {
    if (sys host).name == "Windows" {
        print "❌ Error: NixOS commands are only available on Linux systems"
        print "   This justfile manages NixOS system configuration and cannot run on Windows"
        exit 1
    }
}

# First-time NixOS setup
def "main first-time" [
    host: string  # Hostname for the NixOS configuration
] {
    check-os
    print "🚀 First-time NixOS setup..."
    print "  This will build and switch to the flake configuration"
    print ""
    print "📦 Building NixOS configuration with flakes..."
    sudo nixos-rebuild switch --flake $".#($host)"
    print ""
    print "✅ First-time setup complete!"
    print "💡 Future rebuilds use: just switch"
}

# Show available NixOS configurations
def "main hosts" [
    host: string  # Current hostname
] {
    check-os
    print "Available NixOS configurations:"
    print "  - symbiont    : NixOS on WSL (Windows Subsystem for Linux)"
    print ""
    print $"Current HOST: ($host)"
}

# Doctor: report only problems for NixOS system
def "main doctor" [
    host: string  # Current hostname
] {
    if (sys host).name != "Linux" { return }

    let issues = null | collect-issues [
        {|| nix-common check-lock flake.lock "nix flake update" }
        {|| check-flake }
    ]

    if ($issues | is-empty) { return }
    print $"nixos \(($host)\):"
    for issue in $issues { print $"  ($issue)" }
    exit 1
}

def check-flake []: nothing -> oneof<string, nothing> {
    if (run-cmd { ^nix flake check --no-build }).ok { return null }
    "flake check failed — run: nix flake check"
}

# Show help
def "main help" [] {
    nix-common show-help "NixOS Utilities" "nixos.nu" [
        {name: "first-time <host>", description: "First-time NixOS setup"}
        {name: "hosts <host>", description: "Show available configurations"}
        {name: "doctor <host>", description: "Report problems with fixes"}
        {name: "help", description: "Show this help message"}
    ]
}

def main [] {
    main help
}

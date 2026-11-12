#!/usr/bin/env nu
# NixOS management utilities

use ../../.scripts/nix-common.nu
use ../../.scripts/adt.nu [run-cmd]

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

    mut issues = []

    let lock = "flake.lock"
    if not ($lock | path exists) {
        $issues = ($issues | append "flake.lock missing — run: nix flake update")
    } else {
        let age = (date now) - ((ls -l $lock | get 0.modified) | into datetime)
        if $age > 30day {
            $issues = ($issues | append $"flake.lock is ($age | into int | $in / 86400000000000) days old — run: nix flake update")
        }
    }

    if (run-cmd { ^nix flake check --no-build } | get ok) == false {
        $issues = ($issues | append "flake check failed — run: nix flake check")
    }

    if ($issues | is-empty) { return }
    print $"nixos \(($host)\):"
    $issues | each {|i| print $"  ($i)" } | ignore
    exit 1
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

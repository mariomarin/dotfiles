#!/usr/bin/env nu
# NixOS management utilities

use ../../.scripts/nix-common.nu

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
    print "  This will:"
    print "  1. Enable flakes in current session"
    print "  2. Build and switch to flake configuration"
    print ""
    print "📦 Building NixOS configuration with flakes..."
    sudo nixos-rebuild switch --flake $".#($host)" --extra-experimental-features "nix-command flakes"
    print ""
    print "✅ First-time setup complete!"
    print "💡 Flakes are now enabled system-wide. Future rebuilds use: just switch"
}

# Remote deployment
def "main remote-switch" [
    host: string          # Hostname for the configuration
    target_host: string   # Target host for deployment (user@host)
    --build-host: string  # Optional build host (user@build-server)
] {
    check-os
    if ($target_host | is-empty) {
        print "Error: TARGET_HOST not set. Usage: just remote-switch TARGET_HOST=user@host"
        exit 1
    }
    let build_host_flag = if ($build_host | is-not-empty) { ["--build-host" $build_host] } else { [] }
    nixos-rebuild switch --flake $".#($host)" --target-host $target_host --use-remote-sudo ...$build_host_flag
}

# Remote testing
def "main remote-test" [
    host: string          # Hostname for the configuration
    target_host: string   # Target host for testing (user@host)
    --build-host: string  # Optional build host (user@build-server)
] {
    check-os
    if ($target_host | is-empty) {
        print "Error: TARGET_HOST not set. Usage: just remote-test TARGET_HOST=user@host"
        exit 1
    }
    let build_host_flag = if ($build_host | is-not-empty) { ["--build-host" $build_host] } else { [] }
    nixos-rebuild test --flake $".#($host)" --target-host $target_host --use-remote-sudo ...$build_host_flag
}

# Deploy VM configuration to remote host
# Note: Always deploys "mitosis" VM configuration - this is the only VM config in the flake
def "main deploy-vm" [
    target_host: string   # Target host for deployment (user@host)
    --build-host: string  # Optional build host (user@build-server)
] {
    check-os
    if ($target_host | is-empty) {
        print "Error: TARGET_HOST not set. Usage: just deploy-vm TARGET_HOST=user@host"
        exit 1
    }
    let build_host_flag = if ($build_host | is-not-empty) { ["--build-host" $build_host] } else { [] }
    nixos-rebuild switch --flake ".#mitosis" --target-host $target_host --use-remote-sudo ...$build_host_flag
}

# Show available NixOS configurations
def "main hosts" [
    host: string  # Current hostname
] {
    check-os
    print "Available NixOS configurations:"
    print "  - dendrite    : ThinkPad T470 portable workstation"
    print "  - mitosis     : Virtual machine for testing and replication"
    print "  - symbiont    : NixOS on WSL (Windows Subsystem for Linux)"
    print ""
    print $"Current HOST: ($host)"
}

# Health check for NixOS system
def "main health" [
    host: string  # Current hostname
] {
    check-os
    nix-common print-header $"🔍 NixOS Health Check for ($host)"

    nix-common health-item "NixOS version" (nix-common run-or-default { nixos-version } "unknown")
    nix-common health-item "Hostname" (nix-common run-or-default { hostname } "unknown")

    let gen_result = (do -i { sudo nix-env --list-generations --profile /nix/var/nix/profiles/system } | complete)
    let generation = if $gen_result.exit_code == 0 { $gen_result.stdout | lines | last } else { "unknown" }
    nix-common health-item "Current generation" $generation

    let flake_status = if ("flake.lock" | path exists) { "locked" } else { "⚠️  not locked" }
    nix-common health-item "Flake status" $flake_status

    let syntax = (nix-common run-or-default { nix-instantiate --parse configuration.nix } "❌ invalid")
    nix-common health-item "Configuration syntax" (if $syntax != "❌ invalid" { "valid" } else { $syntax })

    let flake_check = (nix-common run-or-default { nix flake check --no-build } "⚠️  warnings")
    nix-common health-item "Flake check" (if $flake_check != "⚠️  warnings" { "passed" } else { $flake_check })

    nix-common health-item "Nix daemon" (nix-common run-or-default { systemctl is-active nix-daemon.service } "not running")

    let disk_result = (do -i { ^du -sh /nix/store } | complete)
    let disk = if $disk_result.exit_code == 0 { $disk_result.stdout | split row "\t" | first } else { "unknown" }
    nix-common health-item "Disk usage" $disk

    print ""
}

# Show help
def "main help" [] {
    nix-common show-help "NixOS Utilities" "nixos.nu" [
        {name: "first-time <host>", description: "First-time NixOS setup"}
        {name: "remote-switch <host> <target> [--build-host]", description: "Deploy to remote host"}
        {name: "remote-test <host> <target> [--build-host]", description: "Test on remote host"}
        {name: "deploy-vm <target> [--build-host]", description: "Deploy VM config to remote"}
        {name: "hosts <host>", description: "Show available configurations"}
        {name: "health <host>", description: "System health check"}
        {name: "help", description: "Show this help message"}
    ]
}

def main [] {
    main help
}

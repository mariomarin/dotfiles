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
    print "  This will build and switch to the flake configuration"
    print ""
    print "📦 Building NixOS configuration with flakes..."
    sudo nixos-rebuild switch --flake $".#($host)"
    print ""
    print "✅ First-time setup complete!"
    print "💡 Future rebuilds use: just switch"
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
    nix-common nixos-rebuild switch $".#($host)" --target-host $target_host --build-host $build_host
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
    nix-common nixos-rebuild test $".#($host)" --target-host $target_host --build-host $build_host
}

# Deploy VM configuration to remote host
def "main deploy-vm" [
    target_host: string                  # Target host for deployment (user@host)
    --vm-host: string = "mitosis"        # VM hostname (default: mitosis)
    --build-host: string                 # Optional build host (user@build-server)
] {
    check-os
    if ($target_host | is-empty) {
        print "Error: TARGET_HOST not set. Usage: just deploy-vm TARGET_HOST=user@host"
        exit 1
    }
    nix-common nixos-rebuild switch $".#($vm_host)" --target-host $target_host --build-host $build_host
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

    nix-common health-item "NixOS version" (do -i { nixos-version } | complete | get stdout | str trim)
    nix-common health-item "Hostname" (do -i { hostname } | complete | get stdout | str trim)

    let gen_result = (do -i { sudo nix-env --list-generations --profile /nix/var/nix/profiles/system } | complete)
    nix-common health-item "Current generation" (if $gen_result.exit_code == 0 { $gen_result.stdout | lines | last } else { "unknown" })

    nix-common health-item "Flake status" (if ("flake.lock" | path exists) { "locked" } else { "⚠️  not locked" })

    let syntax_result = (do -i { nix-instantiate --parse configuration.nix } | complete)
    nix-common health-item "Configuration syntax" (if $syntax_result.exit_code == 0 { "valid" } else { "❌ invalid" })

    let flake_result = (do -i { nix flake check --no-build } | complete)
    nix-common health-item "Flake check" (if $flake_result.exit_code == 0 { "passed" } else { "⚠️  warnings" })

    nix-common health-item "Nix daemon" (do -i { systemctl is-active nix-daemon.service } | complete | get stdout | str trim)

    let disk_result = (do -i { ^du -sh /nix/store } | complete)
    nix-common health-item "Disk usage" (if $disk_result.exit_code == 0 { $disk_result.stdout | split row "\t" | first } else { "unknown" })

    print ""
}

# Show help
def "main help" [] {
    nix-common show-help "NixOS Utilities" "nixos.nu" [
        {name: "first-time <host>", description: "First-time NixOS setup"}
        {name: "remote-switch <host> <target> [--build-host]", description: "Deploy to remote host"}
        {name: "remote-test <host> <target> [--build-host]", description: "Test on remote host"}
        {name: "deploy-vm <target> [--vm-host] [--build-host]", description: "Deploy VM config (default: mitosis)"}
        {name: "hosts <host>", description: "Show available configurations"}
        {name: "health <host>", description: "System health check"}
        {name: "help", description: "Show this help message"}
    ]
}

def main [] {
    main help
}

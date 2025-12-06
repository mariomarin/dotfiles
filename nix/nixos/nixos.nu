#!/usr/bin/env nu
# NixOS management utilities

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
    ^sudo ^nixos-rebuild switch --flake $".#($host)" --extra-experimental-features "nix-command flakes"
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
    ^nixos-rebuild switch --flake $".#($host)" --target-host $target_host --use-remote-sudo ...$build_host_flag
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
    ^nixos-rebuild test --flake $".#($host)" --target-host $target_host --use-remote-sudo ...$build_host_flag
}

# Deploy VM configuration to remote host
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
    ^nixos-rebuild switch --flake ".#mitosis" --target-host $target_host --use-remote-sudo ...$build_host_flag
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
    print $"🔍 NixOS Health Check for ($host)"
    print "================================"
    let version_result = (do { ^nixos-version } | complete)
    let version = if $version_result.exit_code == 0 { $version_result.stdout | str trim } else { "unknown" }
    print $"✓ NixOS version: ($version)"
    let hostname_result = (do { ^hostname } | complete)
    let hostname = if $hostname_result.exit_code == 0 { $hostname_result.stdout | str trim } else { "unknown" }
    print $"✓ Hostname: ($hostname)"
    let gen_result = (do { ^sudo ^nix-env --list-generations --profile /nix/var/nix/profiles/system } | complete)
    let generation = if $gen_result.exit_code == 0 { $gen_result.stdout | lines | last } else { "unknown" }
    print $"✓ Current generation: ($generation)"
    let flake_status = if ("flake.lock" | path exists) { "locked" } else { "⚠️  not locked" }
    print $"✓ Flake status: ($flake_status)"
    let syntax_result = (do { ^nix-instantiate --parse configuration.nix } | complete)
    let syntax = if $syntax_result.exit_code == 0 { "valid" } else { "❌ invalid" }
    print $"✓ Configuration syntax: ($syntax)"
    let flake_result = (do { ^nix flake check --no-build } | complete)
    let flake_check = if $flake_result.exit_code == 0 { "passed" } else { "⚠️  warnings" }
    print $"✓ Flake check: ($flake_check)"
    let daemon_result = (do { ^systemctl is-active nix-daemon.service } | complete)
    let daemon = if $daemon_result.exit_code == 0 { $daemon_result.stdout | str trim } else { "not running" }
    print $"✓ Nix daemon: ($daemon)"
    let disk_result = (do { ^du -sh /nix/store } | complete)
    let disk = if $disk_result.exit_code == 0 { $disk_result.stdout | split row "\t" | first } else { "unknown" }
    print $"✓ Disk usage: ($disk)"
    print ""
}

# Show help
def "main help" [] {
    print "NixOS Utilities"
    print "==============="
    print ""
    print "Usage: nu nixos.nu <command> [args]"
    print ""
    print "Commands:"
    print "  first-time <host>                           First-time NixOS setup"
    print "  remote-switch <host> <target> [--build-host] Deploy to remote host"
    print "  remote-test <host> <target> [--build-host]   Test on remote host"
    print "  deploy-vm <target> [--build-host]            Deploy VM config to remote"
    print "  hosts <host>                                 Show available configurations"
    print "  health <host>                                System health check"
    print "  help                                         Show this help message"
}

def main [] {
    main help
}

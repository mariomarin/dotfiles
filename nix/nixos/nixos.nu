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

# Check if package is installed
def is-installed [name: string] {
    nix profile list
    | complete
    | get stdout
    | str contains $name
}

# Check if systemd service needs reload
def needs-reload [] {
    systemctl --user show atuin-server.service --property=NeedDaemonReload --value
    | complete
    | get stdout
    | str trim
    | $in == "yes"
}

# Check if service is running
def is-running [] {
    systemctl --user is-active atuin-server.service
    | complete
    | get exit_code
    | $in == 0
}

# Upgrade installed package
def upgrade-package [name: string] {
    print $"↑ Upgrading ($name)..."

    # Update flake inputs to get latest packages
    print "  Updating flake inputs..."
    let update_result = (nix flake update | complete)
    if $update_result.exit_code != 0 {
        print $"  Warning: flake update had issues: ($update_result.stderr)"
    }

    # For buildEnv packages, upgrade doesn't rebuild - must remove and reinstall
    print "  Removing old version..."
    let remove_result = (nix profile remove $".#($name)" | complete)
    if $remove_result.exit_code != 0 {
        print $"  Warning: remove had issues: ($remove_result.stderr)"
    }

    print "  Installing updated version..."
    let result = (nix profile install $".#($name)" | complete)
    if $result.exit_code != 0 {
        print $"✗ Installation failed: ($result.stderr)"
        return 1
    }

    print $"✓ ($name) upgraded"

    if (needs-reload) {
        print "  Reloading systemd daemon..."
        systemctl --user daemon-reload
    }

    if (is-running) {
        print "  Restarting atuin-server..."
        systemctl --user restart atuin-server.service
        print "  ✓ Service restarted"
    }

    print ""
    print "✅ Upgrade complete"
}

# Install fresh package
def install-package [name: string] {
    print $"  Installing ($name) from flake..."

    let result = (nix profile install $".#($name)" | complete)
    if $result.exit_code != 0 {
        print $"✗ Installation failed: ($result.stderr)"
        return 1
    }

    print $"✓ ($name) installed"
    print $"  Binaries: ~/.nix-profile/bin/"
    print ""
    print "✅ Installation complete"
}

# Determine package action based on install status
def package-action [package_name: string, is_installed: bool] {
    if $is_installed {
        { action: "upgrade", package: $package_name }
    } else {
        { action: "install", package: $package_name }
    }
}

# Linux-apt package installation (ribosome)
def "main linux-apt" [
    host: string  # Hostname (ribosome)
] {
    let package_name = $"($host)-env"
    let installed = (is-installed $package_name)
    let decision = (package-action $package_name $installed)

    print "📦 Installing Nix packages for" $host "- linux-apt mode"

    if $decision.action == "upgrade" {
        upgrade-package $decision.package
    } else {
        install-package $decision.package
    }
}

# Show help
def "main help" [] {
    nix-common show-help "NixOS Utilities" "nixos.nu" [
        {name: "first-time <host>", description: "First-time NixOS setup"}
        {name: "remote-switch <host> <target> [--build-host]", description: "Deploy to remote host"}
        {name: "remote-test <host> <target> [--build-host]", description: "Test on remote host"}
        {name: "deploy-vm <target> [--vm-host] [--build-host]", description: "Deploy VM config (default: mitosis)"}
        {name: "linux-apt <host>", description: "Install packages for linux-apt (ribosome)"}
        {name: "hosts <host>", description: "Show available configurations"}
        {name: "health <host>", description: "System health check"}
        {name: "help", description: "Show this help message"}
    ]
}

def main [] {
    main help
}

#!/usr/bin/env nu
# Common utilities for nix-darwin and NixOS management

# Default main function - shows help
export def main [] {
    print "Error: This module should be used by nix-darwin or NixOS utilities"
    print "Use 'nu darwin.nu' or 'nu nixos.nu' instead"
    exit 1
}


# Print a health check item
export def health-item [
    label: string      # Label for the health check item
    value: string      # Value to display
] {
    print $"✓ ($label): ($value)"
}

# Print header with title and underline
export def print-header [
    title: string      # Header title
] {
    print $title
    print ("=" | fill -c "=" -w ($title | str length))
}

# Build nixos-rebuild command with optional build host
export def nixos-rebuild [
    action: string            # Action: switch, test, build
    flake: string             # Flake reference (e.g., ".#host")
    --target-host: string     # Target host for deployment
    --build-host: string      # Optional build host
] {
    mut cmd = ["nixos-rebuild" $action "--flake" $flake]

    if ($target_host | is-not-empty) {
        $cmd = ($cmd | append ["--target-host" $target_host "--use-remote-sudo"])
    }

    if ($build_host | is-not-empty) {
        $cmd = ($cmd | append ["--build-host" $build_host])
    }

    run-external ...$cmd
}

# Generic help display function
export def show-help [
    title: string         # Title (e.g., "NixOS Utilities")
    script_name: string   # Script name (e.g., "nixos.nu")
    commands: list        # List of records with 'name' and 'description'
] {
    print $title
    print ("=" | fill -c "=" -w ($title | str length))
    print ""
    print $"Usage: nu ($script_name) <command> [args]"
    print ""
    print "Commands:"
    for cmd in $commands {
        let padded_name = ($cmd.name | fill -c " " -w 50 -a left)
        print $"  ($padded_name)($cmd.description)"
    }
}

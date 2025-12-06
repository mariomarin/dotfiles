#!/usr/bin/env nu
# Common utilities for nix-darwin and NixOS management

# Default main function - shows help
export def main [] {
    print "Error: This module should be used by nix-darwin or NixOS utilities"
    print "Use 'nu darwin.nu' or 'nu nixos.nu' instead"
    exit 1
}

# Run a command and return result or default value
export def run-or-default [
    command: closure   # Command to run
    default: string    # Default value if command fails
] {
    let result = (do -i $command | complete)
    if $result.exit_code == 0 and ($result.stdout | str trim | is-not-empty) {
        $result.stdout | str trim
    } else {
        $default
    }
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

#!/usr/bin/env nu
# Common utilities for nix-darwin and NixOS management

# Default main function - shows help
export def main [] {
    print "Error: This module should be used by nix-darwin or NixOS utilities"
    print "Use 'nu darwin.nu' or 'nu nixos.nu' instead"
    exit 1
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

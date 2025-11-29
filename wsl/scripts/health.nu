#!/usr/bin/env nu
# Health check for WSL setup

print "🏥 WSL NixOS Health Check"
print "========================="
print ""

# Check WSL
print "WSL Installation:"
let wsl_installed = (do { wsl --version } | complete | get exit_code) == 0
if $wsl_installed {
    print "  ✅ WSL2 installed"
} else {
    print "  ❌ WSL2 not installed"
}

# Check if NixOS is imported
print ""
print "NixOS Distribution:"
let nixos_exists = (wsl --list --quiet | lines | any {|line| $line =~ "NixOS" })
if $nixos_exists {
    print "  ✅ NixOS imported"

    # Check if running
    let nixos_running = (wsl --list --running | lines | any {|line| $line =~ "NixOS" })
    if $nixos_running {
        print "  ✅ NixOS running"
    } else {
        print "  ⚠️  NixOS not running (start with: just start-nixos)"
    }
} else {
    print "  ❌ NixOS not imported (run: just import-nixos)"
}

print ""

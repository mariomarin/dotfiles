#!/usr/bin/env nu
# WSL NixOS Setup and Management Script
# Main entry point with subcommands

use ../.scripts/adt.nu [run-cmd, is-err, "result map", "result unwrap-or", "result try"]

# Check if running on Windows
def check-os [] {
    if $nu.os-info.name != "windows" {
        print -e "❌ Error: WSL setup commands are only for Windows"
        print -e "   These commands help set up NixOS on WSL2 from Windows"
        exit 1
    }
}

# wsl.exe writes UTF-16LE unless WSL_UTF8=1 (older builds ignore it); read
# as UTF-8 that is text with a NUL after every character, so strip NULs.
def wsl-text []: string -> string {
    str replace -a (char nul) ""
}

# Run wsl.exe for its output: Result of NUL-free stdout
def --wrapped wsl-run [...args: string]: nothing -> record {
    with-env {WSL_UTF8: "1"} { run-cmd { ^wsl ...$args } }
    | result map {|out| $out.stdout | wsl-text }
}

# Run wsl.exe attached to the terminal (interactive, streamed): Result
def --wrapped wsl-run-attached [...args: string]: nothing -> record {
    null | result try {|_| ^wsl ...$args; null }
}

def has-wsl []: nothing -> bool {
    (wsl-run --version).ok
}

# Distro names from `wsl --list --quiet` output
def parse-distros [stdout: string]: nothing -> list<string> {
    $stdout | wsl-text | lines | str trim | where {|l| $l | is-not-empty }
}

# Whether a distro is listed (--running: only running ones)
def has-distro [name: string, --running]: nothing -> bool {
    let flags = if $running { [--running] } else { [] }
    $name in (
        wsl-run --list --quiet ...$flags
        | result map {|out| parse-distros $out }
        | result unwrap-or []
    )
}

# Target NixOS configuration (see nix/nixos/flake.nix)
const NIX_HOST = "symbiont"
const NIX_USER = "mario"
const NIX_FLAKE = "github:mariomarin/dotfiles?dir=nix/nixos"

# Hostname of the NixOS distro, or null if it cannot be queried
def find-nixos-hostname []: nothing -> oneof<string, nothing> {
    wsl-run -d NixOS -u root --exec hostname
    | result map {|out| $out | str trim }
    | result unwrap-or null
}

def is-provisioned []: nothing -> bool {
    (find-nixos-hostname) == $NIX_HOST
}

def has-dotfiles []: nothing -> bool {
    let source = $"/home/($NIX_USER)/.local/share/chezmoi"
    (wsl-run -d NixOS -u $NIX_USER --exec test -d $source).ok
}

# Check if WSL2 is installed
def "main check-wsl" []: nothing -> nothing {
    check-os
    print "🔍 Checking WSL2 installation..."
    match (wsl-run --version) {
        {ok: true, value: $version} => {
            print $version
            print "✅ WSL2 is installed"
        }
        _ => {
            print -e "❌ WSL is not installed"
            print -e "   Run: nu wsl.nu install-wsl"
            exit 1
        }
    }
}

# Install WSL2 (requires Administrator privileges)
def "main install-wsl" []: nothing -> nothing {
    check-os
    # Check if WSL is already installed
    if (has-wsl) {
        print "✅ WSL2 is already installed"
        print (wsl-run --version | result unwrap-or "")
        exit 0
    }

    print "📦 Installing WSL2..."
    print "⚠️  This requires Administrator privileges"
    print "   You may be prompted for elevation"
    print ""
    wsl --install
    print ""
    print "✅ WSL2 installation started"
    print "💡 You may need to restart your computer"
    print "   After restart, run: nu wsl.nu check-wsl"
}

# Import NixOS into WSL
def "main import-nixos" []: nothing -> nothing {
    check-os
    # Check if NixOS is already imported
    if (has-distro NixOS) {
        print "✅ NixOS is already imported in WSL"
        print ""
        print "To reinstall with a new version:"
        print "  1. nu wsl.nu uninstall-nixos"
        print "  2. nu wsl.nu import-nixos"
        exit 0
    }

    print "📦 Importing NixOS into WSL..."

    if not ("nixos.wsl" | path exists) {
        print -e "❌ nixos.wsl not found"
        print -e "   Run 'chezmoi apply' from parent directory to download it"
        exit 1
    }

    let nixos_path = $env.USERPROFILE | path join "NixOS"
    print $"📂 Installation path: ($nixos_path)"

    # Import NixOS distribution
    wsl --import NixOS $nixos_path nixos.wsl --version 2

    print "✅ NixOS imported successfully"
    print "💡 Next steps:"
    print "   1. nu wsl.nu start-nixos"
    print "   2. Inside WSL, set up dotfiles with chezmoi"
}

# Start NixOS WSL instance
def "main start-nixos" []: nothing -> nothing {
    check-os
    print "🚀 Starting NixOS WSL..."
    wsl -d NixOS
}

# List installed WSL distributions
def "main list-distros" []: nothing -> nothing {
    check-os
    print "📋 Installed WSL distributions:"
    wsl --list --verbose
}

# Set NixOS as default WSL distribution
def "main set-default" []: nothing -> nothing {
    check-os
    print "⚙️  Setting NixOS as default WSL distribution..."
    wsl --set-default NixOS
    print "✅ NixOS is now the default WSL distribution"
    print "💡 You can now use 'wsl' to start NixOS directly"
}

# Stop NixOS WSL instance
def "main stop-nixos" []: nothing -> nothing {
    check-os
    print "🛑 Stopping NixOS WSL..."
    wsl --terminate NixOS
    print "✅ NixOS WSL stopped"
}

# Unregister/remove NixOS from WSL
def "main uninstall-nixos" []: nothing -> nothing {
    check-os
    print "⚠️  WARNING: This will remove NixOS and all its data!"
    print "Press Ctrl+C to cancel, or Enter to continue..."
    input

    print "🗑️  Unregistering NixOS from WSL..."
    wsl --unregister NixOS

    print "✅ NixOS unregistered from WSL"
    print "💡 You can reinstall with: nu wsl.nu import-nixos"
}

# Run a command in NixOS WSL
def "main run" [
    command: string  # Command to run in NixOS WSL
]: nothing -> nothing {
    check-os
    wsl -d NixOS --exec $command
}

# Open NixOS WSL in Windows Terminal
def "main terminal" []: nothing -> nothing {
    check-os
    print "🖥️  Opening NixOS in Windows Terminal..."
    wt -w 0 new-tab -p "NixOS"
}

# Show WSL system information
def "main info" []: nothing -> nothing {
    check-os
    print "ℹ️  WSL System Information"
    print "========================="
    print ""
    wsl --status
    print ""
    print "NixOS Distribution Info:"
    wsl -d NixOS --exec cat /etc/os-release
}

# Health check for WSL setup
def "main doctor" []: nothing -> nothing {
    check-os
    mut issues = []

    if not (has-wsl) {
        $issues ++= ["WSL2 not installed — run: wsl --install"]
        print "wsl:"
        $issues | each {|i| print $"  ($i)" } | ignore
        exit 1
    }

    if not (has-distro NixOS) {
        $issues ++= ["NixOS not imported — run: just wsl-setup"]
    } else {
        if not (has-distro NixOS --running) {
            $issues ++= ["NixOS not running — run: just wsl-start"]
        }
    }

    if ($issues | is-empty) { return }
    print "wsl:"
    $issues | each {|i| print $"  ($i)" } | ignore
    exit 1
}

# Switch the fresh distro to the flake config (hostname, user, packages)
def "main provision-nixos" []: nothing -> nothing {
    check-os
    if (is-provisioned) { return }

    let rebuild = (wsl-run-attached -d NixOS -u root --exec nixos-rebuild switch
        --flake $"($NIX_FLAKE)#($NIX_HOST)"
        --extra-experimental-features "nix-command flakes")
    if ($rebuild | is-err) {
        print -e "❌ nixos-rebuild failed — rerun: nu wsl.nu provision-nixos"
        exit 1
    }

    # Restart so the new hostname and default user take effect
    wsl --terminate NixOS
}

# Unlock Bitwarden and apply chezmoi dotfiles (interactive)
def "main apply-dotfiles" []: nothing -> nothing {
    check-os
    if (has-dotfiles) { return }

    print "🔐 Bitwarden will prompt for your password"
    let script = [
        "set -e"
        "bw login --check >/dev/null 2>&1 || bw login"
        "BW_SESSION=$(bw unlock --raw)"
        "export BW_SESSION"
        "chezmoi init --apply mariomarin"
    ] | str join "; "
    if (wsl-run-attached -d NixOS -u $NIX_USER --exec bash -lc $script | is-err) {
        print -e "❌ Applying dotfiles failed — rerun: nu wsl.nu apply-dotfiles"
        exit 1
    }
}

# Complete WSL NixOS setup (one-command install)
def "main setup" []: nothing -> nothing {
    check-os
    print "🚀 Complete WSL NixOS Setup"
    print "==========================="
    print ""
    print "This will:"
    print "  1. Check/Install WSL2"
    print "  2. Import NixOS into WSL (tarball downloaded via chezmoi)"
    print "  3. Set NixOS as default"
    print $"  4. Build the ($NIX_HOST) NixOS configuration"
    print "  5. Apply dotfiles (prompts for Bitwarden password)"
    print ""
    print "⚠️  Note: Run 'chezmoi apply' first to download nixos.wsl"
    print ""
    print "Press Ctrl+C to cancel, or Enter to continue..."
    input

    # Step 1: Check WSL
    print ""
    print "Step 1: Checking WSL2..."
    if not (has-wsl) {
        print "Installing WSL2..."
        main install-wsl
        print "⚠️  Please restart your computer and run 'nu wsl.nu setup' again"
        exit 0
    }
    print "✅ WSL2 is installed"

    # Step 2: Check for NixOS tarball
    print ""
    print "Step 2: Checking for NixOS-WSL tarball..."
    if not ("nixos.wsl" | path exists) {
        print -e "❌ nixos.wsl not found"
        print -e ""
        print -e "The tarball is downloaded automatically by chezmoi."
        print -e "Please run 'chezmoi apply' from the parent directory first:"
        print -e ""
        print -e "  cd .."
        print -e "  chezmoi apply"
        print -e "  cd wsl"
        print -e "  just setup"
        exit 1
    }
    print "✅ nixos.wsl found"

    # Step 3: Import NixOS
    print ""
    print "Step 3: Importing NixOS..."
    let nixos_exists = (has-distro NixOS)

    if not $nixos_exists {
        main import-nixos
    } else {
        print "✅ NixOS already imported"
        print "💡 To reinstall, run: nu wsl.nu uninstall-nixos"
    }

    # Step 4: Set as default
    print ""
    print "Step 4: Setting NixOS as default..."
    main set-default

    # Step 5: Build system configuration
    print ""
    print "Step 5: Provisioning NixOS..."
    main provision-nixos

    # Step 6: Dotfiles
    print ""
    print "Step 6: Applying dotfiles..."
    main apply-dotfiles

    print ""
    print "✨ Setup complete! Start NixOS with: wsl"
    print "💡 Future rebuilds (inside WSL): just nixos-switch"
}

# Show help
def "main help" []: nothing -> nothing {
    print "WSL NixOS Setup and Management"
    print "==============================="
    print ""
    print "Usage: nu wsl.nu <command>"
    print ""
    print "Prerequisites:"
    print "  Run 'chezmoi apply' first to download nixos.wsl"
    print ""
    print "Commands:"
    print "  check-wsl        Check if WSL2 is installed"
    print "  install-wsl      Install WSL2 (requires Admin)"
    print "  import-nixos     Import NixOS into WSL"
    print "  start-nixos      Start NixOS WSL instance"
    print "  list-distros     List installed WSL distributions"
    print "  set-default      Set NixOS as default distribution"
    print "  provision-nixos  Build the flake NixOS configuration"
    print "  apply-dotfiles   Unlock Bitwarden and apply chezmoi"
    print "  stop-nixos       Stop NixOS WSL instance"
    print "  uninstall-nixos  Unregister/remove NixOS from WSL"
    print "  run <command>    Run a command in NixOS WSL"
    print "  terminal         Open NixOS in Windows Terminal"
    print "  info             Show WSL system information"
    print "  doctor           Report problems with fixes"
    print "  setup            Complete automated setup"
    print "  help             Show this help message"
    print ""
    print "Note: The NixOS-WSL file (nixos.wsl) is downloaded automatically by chezmoi"
    print "      when you run 'chezmoi apply' on Windows systems."
}

def main []: nothing -> nothing {
    main help
}

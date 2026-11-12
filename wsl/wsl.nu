#!/usr/bin/env nu
# WSL NixOS Setup and Management Script
# Main entry point with subcommands

use ../.scripts/adt.nu [
    run-cmd
    is-err
    collect-issues
    "result map"
    "result unwrap-or"
    "result try"
]

# Target NixOS configuration (see nix/nixos/flake.nix)
const NIX_HOST = "symbiont"
const NIX_USER = "mario"
const NIX_FLAKE = "github:mariomarin/dotfiles?dir=nix/nixos"

# Print lines as one block (--stderr for errors)
def print-lines [--stderr]: list<string> -> nothing {
    let text = $in | str join "\n"
    print --stderr=$stderr $text
}

# Fail unless running on Windows
def check-os []: nothing -> nothing {
    if $nu.os-info.name != windows {
        error make {msg: "WSL setup commands are only for Windows", help: "These commands set up NixOS on WSL2 from a Windows host"}
    }
}

# wsl.exe writes UTF-16LE unless WSL_UTF8=1 (older builds ignore it); read
# as UTF-8 that is text with a NUL after every character, so strip NULs.
def wsl-text []: string -> string {
    str replace --all (char nul) ""
}

# Run wsl.exe for its output: Result of NUL-free stdout
def --wrapped wsl-run [...args: string]: nothing -> record {
    with-env {WSL_UTF8: "1"} { run-cmd { wsl ...$args } }
    | result map {|out| $out.stdout | wsl-text }
}

# Run wsl.exe attached to the terminal (interactive, streamed): Result
def --wrapped wsl-run-attached [...args: string]: nothing -> record {
    null | result try {|_| wsl ...$args; null }
}

def has-wsl []: nothing -> bool {
    (wsl-run --version).ok
}

# Distro names from `wsl --list --quiet` output
def parse-distros []: string -> list<string> {
    wsl-text | lines | str trim | compact --empty
}

# Whether a distro is listed (--running: only running ones)
def has-distro [name: string, --running]: nothing -> bool {
    let flags = if $running { [--running] } else { [] }
    $name in (
        wsl-run --list --quiet ...$flags
        | result map {|out| $out | parse-distros }
        | result unwrap-or []
    )
}

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

# Problems with the WSL setup; each check is gated on the one before it,
# and the in-distro checks only run while NixOS is up (they would boot it)
def find-issues []: nothing -> list<string> {
    let wsl = (has-wsl)
    let imported = $wsl and (has-distro NixOS)
    let running = $imported and (has-distro NixOS --running)
    null | collect-issues [
        {||
            if not $wsl { "WSL2 not installed — run: wsl --install" }
        }
        {||
            if $wsl and not $imported { "NixOS not imported — run: just wsl-setup" }
        }
        {||
            if $imported and not $running { "NixOS not running — run: just wsl-start" }
        }
        {||
            if $running and not (is-provisioned) { "NixOS not provisioned — run: just wsl/provision-nixos" }
        }
        {||
            if $running and not (has-dotfiles) { "Dotfiles not applied — run: just wsl/apply-dotfiles" }
        }
    ]
}

# Check if WSL2 is installed
def "main check-wsl" []: nothing -> nothing {
    check-os
    print "🔍 Checking WSL2 installation..."
    match (wsl-run --version) {
        {ok: true, value: $version} => {
            [$version "✅ WSL2 is installed"] | print-lines
        }
        _ => {
            ["❌ WSL is not installed" "   Run: nu wsl.nu install-wsl"] | print-lines --stderr
            exit 1
        }
    }
}

# Install WSL2 (requires Administrator privileges)
def "main install-wsl" []: nothing -> nothing {
    check-os
    if (has-wsl) {
        [
            "✅ WSL2 is already installed"
            (wsl-run --version | result unwrap-or "")
        ] | print-lines
        exit 0
    }

    [
        "📦 Installing WSL2..."
        "⚠️  This requires Administrator privileges"
        "   You may be prompted for elevation"
        ""
    ] | print-lines
    wsl --install
    [
        ""
        "✅ WSL2 installation started"
        "💡 You may need to restart your computer"
        "   After restart, run: nu wsl.nu check-wsl"
    ] | print-lines
}

# Import NixOS into WSL
def "main import-nixos" []: nothing -> nothing {
    check-os
    if (has-distro NixOS) {
        [
            "✅ NixOS is already imported in WSL"
            ""
            "To reinstall with a new version:"
            "  1. nu wsl.nu uninstall-nixos"
            "  2. nu wsl.nu import-nixos"
        ] | print-lines
        exit 0
    }

    print "📦 Importing NixOS into WSL..."

    if not ("nixos.wsl" | path exists) {
        [
            "❌ nixos.wsl not found"
            "   Run 'chezmoi apply' from parent directory to download it"
        ] | print-lines --stderr
        exit 1
    }

    let nixos_path = $env.USERPROFILE | path join NixOS
    print $"📂 Installation path: ($nixos_path)"
    wsl --import NixOS $nixos_path nixos.wsl --version 2
    [
        "✅ NixOS imported successfully"
        "💡 Next steps:"
        "   1. nu wsl.nu start-nixos"
        "   2. Inside WSL, set up dotfiles with chezmoi"
    ] | print-lines
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
    [
        "✅ NixOS is now the default WSL distribution"
        "💡 You can now use 'wsl' to start NixOS directly"
    ] | print-lines
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
    [
        "⚠️  WARNING: This will remove NixOS and all its data!"
        "Press Ctrl+C to cancel, or Enter to continue..."
    ] | print-lines
    input

    print "🗑️  Unregistering NixOS from WSL..."
    wsl --unregister NixOS
    [
        "✅ NixOS unregistered from WSL"
        "💡 You can reinstall with: nu wsl.nu import-nixos"
    ] | print-lines
}

# Run a command in NixOS WSL
def "main run" [
    command: string # Command to run in NixOS WSL
]: nothing -> nothing {
    check-os
    wsl -d NixOS --exec $command
}

# Open NixOS WSL in Windows Terminal
def "main terminal" []: nothing -> nothing {
    check-os
    print "🖥️  Opening NixOS in Windows Terminal..."
    wt -w 0 new-tab -p NixOS
}

# Show WSL system information
def "main info" []: nothing -> nothing {
    check-os
    [
        "ℹ️  WSL System Information"
        "========================="
        ""
    ] | print-lines
    wsl --status
    ["" "NixOS Distribution Info:"] | print-lines
    wsl -d NixOS --exec cat /etc/os-release
}

# Health check for WSL setup: report only problems
def "main doctor" []: nothing -> nothing {
    check-os
    let issues = (find-issues)
    if ($issues | is-empty) { return }
    [
        "wsl:"
        ...($issues | each {|issue| $"  ($issue)" })
    ] | print-lines
    exit 1
}

# Switch the fresh distro to the flake config (hostname, user, packages)
def "main provision-nixos" []: nothing -> nothing {
    check-os
    if (is-provisioned) { return }

    let script = [
        "NIX_CONFIG='experimental-features = nix-command flakes'"
        "nixos-rebuild switch --refresh"
        $"--flake '($NIX_FLAKE)#($NIX_HOST)'"
    ] | str join " "

    let rebuild = (wsl-run-attached -d NixOS -u root --exec bash -lc $script)
    if ($rebuild | is-err) {
        print --stderr "❌ nixos-rebuild failed — rerun: nu wsl.nu provision-nixos"
        exit 1
    }

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
        print --stderr "❌ Applying dotfiles failed — rerun: nu wsl.nu apply-dotfiles"
        exit 1
    }
}

# Complete WSL NixOS setup (one-command install)
def "main setup" []: nothing -> nothing {
    check-os
    [
        "🚀 Complete WSL NixOS Setup"
        "==========================="
        ""
        "This will:"
        "  1. Check/Install WSL2"
        "  2. Import NixOS into WSL (tarball downloaded via chezmoi)"
        "  3. Set NixOS as default"
        $"  4. Build the ($NIX_HOST) NixOS configuration"
        "  5. Apply dotfiles (prompts for Bitwarden password)"
    ] | print-lines

    ["" "Step 1: Checking WSL2..."] | print-lines
    if not (has-wsl) {
        print "Installing WSL2..."
        main install-wsl
        print "⚠️  Please restart your computer and run 'nu wsl.nu setup' again"
        exit 0
    }
    print "✅ WSL2 is installed"

    ["" "Step 2: Checking for NixOS-WSL tarball..."] | print-lines
    if not ("nixos.wsl" | path exists) {
        [
            "❌ nixos.wsl not found in the wsl directory"
            ""
            "chezmoi downloads it on Windows. Run 'chezmoi apply' first:"
            ""
            "  cd .."
            "  chezmoi apply"
            "  cd wsl"
            "  just setup"
        ] | print-lines --stderr
        exit 1
    }
    print "✅ nixos.wsl found"

    ["" "Step 3: Importing NixOS..."] | print-lines
    if (has-distro NixOS) {
        [
            "✅ NixOS already imported"
            "💡 To reinstall, run: nu wsl.nu uninstall-nixos"
        ] | print-lines
    } else {
        main import-nixos
    }

    ["" "Step 4: Setting NixOS as default..."] | print-lines
    main set-default

    ["" "Step 5: Provisioning NixOS..."] | print-lines
    main provision-nixos

    ["" "Step 6: Applying dotfiles..."] | print-lines
    main apply-dotfiles

    [
        ""
        "✨ Setup complete! Start NixOS with: wsl"
        "💡 Future rebuilds (inside WSL): just nixos-switch"
    ] | print-lines
}

# Show help
def "main help" []: nothing -> nothing {
    [
        "WSL NixOS Setup and Management"
        "==============================="
        ""
        "Usage: nu wsl.nu <command>"
        ""
        "Prerequisites:"
        "  Run 'chezmoi apply' first to download nixos.wsl"
        ""
        "Commands:"
        "  check-wsl        Check if WSL2 is installed"
        "  install-wsl      Install WSL2 (requires Admin)"
        "  import-nixos     Import NixOS into WSL"
        "  start-nixos      Start NixOS WSL instance"
        "  list-distros     List installed WSL distributions"
        "  set-default      Set NixOS as default distribution"
        "  provision-nixos  Build the flake NixOS configuration"
        "  apply-dotfiles   Unlock Bitwarden and apply chezmoi"
        "  stop-nixos       Stop NixOS WSL instance"
        "  uninstall-nixos  Unregister/remove NixOS from WSL"
        "  run <command>    Run a command in NixOS WSL"
        "  terminal         Open NixOS in Windows Terminal"
        "  info             Show WSL system information"
        "  doctor           Report problems with fixes"
        "  setup            Complete automated setup"
        "  help             Show this help message"
        ""
        "Note: The NixOS-WSL file (nixos.wsl) is downloaded automatically by chezmoi"
        "      when you run 'chezmoi apply' on Windows systems."
    ] | print-lines
}

def main []: nothing -> nothing {
    main help
}

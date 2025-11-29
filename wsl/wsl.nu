#!/usr/bin/env nu
# WSL NixOS Setup and Management Script
# Main entry point with subcommands

# Check if running on Windows
def check-os [] {
    if $nu.os-info.name != "windows" {
        print "❌ Error: WSL setup commands are only for Windows"
        print "   These commands help set up NixOS on WSL2 from Windows"
        exit 1
    }
}

# Check if WSL2 is installed
def "main check-wsl" [] {
    check-os
    print "🔍 Checking WSL2 installation..."
    let result = (do { wsl --version } | complete)
    if $result.exit_code != 0 {
        print "❌ WSL is not installed"
        print "   Run: nu wsl.nu install-wsl"
        exit 1
    }
    print $result.stdout
    print "✅ WSL2 is installed"
}

# Install WSL2 (requires Administrator privileges)
def "main install-wsl" [] {
    check-os
    # Check if WSL is already installed
    let wsl_installed = (do { wsl --version } | complete | get exit_code) == 0
    if $wsl_installed {
        print "✅ WSL2 is already installed"
        wsl --version
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

# Download latest NixOS-WSL tarball
def "main download-nixos" [] {
    check-os
    # Check if already downloaded
    if ("nixos-wsl.tar.gz" | path exists) {
        print "✅ nixos-wsl.tar.gz already exists"
        print "💡 To re-download, delete the file first: rm nixos-wsl.tar.gz"
        exit 0
    }

    print "📥 Downloading latest NixOS-WSL..."

    # Fetch latest release info from GitHub
    let release_url = "https://api.github.com/repos/nix-community/NixOS-WSL/releases/latest"
    let release_info = (http get $release_url)
    let version = $release_info.tag_name
    let download_url = ($release_info.assets | where name =~ "nixos-wsl.tar.gz" | first | get browser_download_url)

    print $"📦 Latest version: ($version)"
    print $"🔗 Download URL: ($download_url)"
    print ""

    # Download to current directory
    print "⏬ Downloading..."
    http get $download_url | save nixos-wsl.tar.gz

    print "✅ Downloaded nixos-wsl.tar.gz"
    print "💡 Next step: nu wsl.nu import-nixos"
}

# Import NixOS into WSL
def "main import-nixos" [] {
    check-os
    # Check if NixOS is already imported
    let nixos_exists = (wsl --list --quiet | lines | any {|line| $line =~ "NixOS" })
    if $nixos_exists {
        print "✅ NixOS is already imported in WSL"
        print "💡 To reinstall, first run: nu wsl.nu uninstall-nixos"
        exit 0
    }

    print "📦 Importing NixOS into WSL..."

    if not ("nixos-wsl.tar.gz" | path exists) {
        print "❌ nixos-wsl.tar.gz not found"
        print "   Run: nu wsl.nu download-nixos"
        exit 1
    }

    let nixos_path = ($env.USERPROFILE | path join "NixOS")
    print $"📂 Installation path: ($nixos_path)"

    # Import NixOS distribution
    wsl --import NixOS $nixos_path nixos-wsl.tar.gz --version 2

    print "✅ NixOS imported successfully"
    print "💡 Next steps:"
    print "   1. nu wsl.nu start-nixos"
    print "   2. Inside WSL, set up dotfiles with chezmoi"
}

# Start NixOS WSL instance
def "main start-nixos" [] {
    check-os
    print "🚀 Starting NixOS WSL..."
    wsl -d NixOS
}

# List installed WSL distributions
def "main list-distros" [] {
    check-os
    print "📋 Installed WSL distributions:"
    wsl --list --verbose
}

# Set NixOS as default WSL distribution
def "main set-default" [] {
    check-os
    print "⚙️  Setting NixOS as default WSL distribution..."
    wsl --set-default NixOS
    print "✅ NixOS is now the default WSL distribution"
    print "💡 You can now use 'wsl' to start NixOS directly"
}

# Stop NixOS WSL instance
def "main stop-nixos" [] {
    check-os
    print "🛑 Stopping NixOS WSL..."
    wsl --terminate NixOS
    print "✅ NixOS WSL stopped"
}

# Unregister/remove NixOS from WSL
def "main uninstall-nixos" [] {
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
] {
    check-os
    wsl -d NixOS --exec $command
}

# Open NixOS WSL in Windows Terminal
def "main terminal" [] {
    check-os
    print "🖥️  Opening NixOS in Windows Terminal..."
    wt -w 0 new-tab -p "NixOS"
}

# Show WSL system information
def "main info" [] {
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
def "main health" [] {
    check-os
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
            print "  ⚠️  NixOS not running (start with: nu wsl.nu start-nixos)"
        }
    } else {
        print "  ❌ NixOS not imported (run: nu wsl.nu import-nixos)"
    }

    print ""
}

# Complete WSL NixOS setup (one-command install)
def "main setup" [] {
    check-os
    print "🚀 Complete WSL NixOS Setup"
    print "==========================="
    print ""
    print "This will:"
    print "  1. Check/Install WSL2"
    print "  2. Download NixOS-WSL"
    print "  3. Import NixOS into WSL"
    print "  4. Set NixOS as default"
    print ""
    print "Press Ctrl+C to cancel, or Enter to continue..."
    input

    # Step 1: Check WSL
    print ""
    print "Step 1: Checking WSL2..."
    let wsl_installed = (do { wsl --version } | complete | get exit_code) == 0
    if not $wsl_installed {
        print "Installing WSL2..."
        main install-wsl
        print "⚠️  Please restart your computer and run 'nu wsl.nu setup' again"
        exit 0
    }
    print "✅ WSL2 is installed"

    # Step 2: Download NixOS
    print ""
    print "Step 2: Downloading NixOS-WSL..."
    if not ("nixos-wsl.tar.gz" | path exists) {
        main download-nixos
    } else {
        print "✅ nixos-wsl.tar.gz already downloaded"
    }

    # Step 3: Import NixOS
    print ""
    print "Step 3: Importing NixOS..."
    let nixos_exists = (wsl --list --quiet | lines | any {|line| $line =~ "NixOS" })
    if not $nixos_exists {
        main import-nixos
    } else {
        print "✅ NixOS already imported"
    }

    # Step 4: Set as default
    print ""
    print "Step 4: Setting NixOS as default..."
    main set-default

    print ""
    print "✨ Setup complete!"
    print ""
    print "Next steps:"
    print "  1. Start NixOS: nu wsl.nu start-nixos"
    print "  2. Inside WSL, install chezmoi: nix-shell -p chezmoi"
    print "  3. Apply dotfiles: chezmoi init --apply YOUR_USERNAME"
    print "  4. Build NixOS config: cd ~/.local/share/chezmoi && just nixos/switch"
}

# Show help
def "main help" [] {
    print "WSL NixOS Setup and Management"
    print "==============================="
    print ""
    print "Usage: nu wsl.nu <command>"
    print ""
    print "Commands:"
    print "  check-wsl        Check if WSL2 is installed"
    print "  install-wsl      Install WSL2 (requires Admin)"
    print "  download-nixos   Download latest NixOS-WSL tarball"
    print "  import-nixos     Import NixOS into WSL"
    print "  start-nixos      Start NixOS WSL instance"
    print "  list-distros     List installed WSL distributions"
    print "  set-default      Set NixOS as default distribution"
    print "  stop-nixos       Stop NixOS WSL instance"
    print "  uninstall-nixos  Unregister/remove NixOS from WSL"
    print "  run <command>    Run a command in NixOS WSL"
    print "  terminal         Open NixOS in Windows Terminal"
    print "  info             Show WSL system information"
    print "  health           Health check for WSL setup"
    print "  setup            Complete automated setup"
    print "  help             Show this help message"
}

def main [] {
    main help
}

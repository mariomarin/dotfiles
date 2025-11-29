#!/usr/bin/env nu
# Complete WSL NixOS setup (one-command install)

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
    just install-wsl
    print "⚠️  Please restart your computer and run 'just setup' again"
    exit 0
}
print "✅ WSL2 is installed"

# Step 2: Download NixOS
print ""
print "Step 2: Downloading NixOS-WSL..."
if not ("nixos-wsl.tar.gz" | path exists) {
    just download-nixos
} else {
    print "✅ nixos-wsl.tar.gz already downloaded"
}

# Step 3: Import NixOS
print ""
print "Step 3: Importing NixOS..."
let nixos_exists = (wsl --list --quiet | lines | any {|line| $line =~ "NixOS" })
if not $nixos_exists {
    just import-nixos
} else {
    print "✅ NixOS already imported"
}

# Step 4: Set as default
print ""
print "Step 4: Setting NixOS as default..."
just set-default

print ""
print "✨ Setup complete!"
print ""
print "Next steps:"
print "  1. Start NixOS: just start-nixos"
print "  2. Inside WSL, install chezmoi: nix-shell -p chezmoi"
print "  3. Apply dotfiles: chezmoi init --apply YOUR_USERNAME"
print "  4. Build NixOS config: cd ~/.local/share/chezmoi && just nixos/switch"

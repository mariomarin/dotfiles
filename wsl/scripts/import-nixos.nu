#!/usr/bin/env nu
# Import NixOS into WSL

# Check if NixOS is already imported
let nixos_exists = (wsl --list --quiet | lines | any {|line| $line =~ "NixOS" })
if $nixos_exists {
    print "✅ NixOS is already imported in WSL"
    print "💡 To reinstall, first run: just uninstall-nixos"
    exit 0
}

print "📦 Importing NixOS into WSL..."

if not ("nixos-wsl.tar.gz" | path exists) {
    print "❌ nixos-wsl.tar.gz not found"
    print "   Run: just download-nixos"
    exit 1
}

let nixos_path = ($env.USERPROFILE | path join "NixOS")
print $"📂 Installation path: ($nixos_path)"

# Import NixOS distribution
wsl --import NixOS $nixos_path nixos-wsl.tar.gz --version 2

print "✅ NixOS imported successfully"
print "💡 Next steps:"
print "   1. just start-nixos"
print "   2. Inside WSL, set up dotfiles with chezmoi"

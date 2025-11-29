#!/usr/bin/env nu
# Download latest NixOS-WSL tarball

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
print $"💡 Next step: just import-nixos"

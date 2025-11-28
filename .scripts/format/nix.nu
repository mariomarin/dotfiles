#!/usr/bin/env nu
# Format Nix files with nixpkgs-fmt

print "📝 Formatting Nix files with nixpkgs-fmt..."
if (which nixpkgs-fmt | is-empty) {
    print "⚠️  nixpkgs-fmt not found. Run 'devenv shell' or 'direnv allow' to load development environment"
    exit 0
}
glob **/*.nix | each {|file| nixpkgs-fmt $file }
print "✅ Nix files formatted"

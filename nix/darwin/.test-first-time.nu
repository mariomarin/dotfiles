#!/usr/bin/env nu
# Test script for first-time darwin setup

print "🚀 First-time nix-darwin setup..."
print "  This will install nix-darwin and apply the configuration"
print ""
print "⚠️  Note: This assumes Nix is already installed via Determinate Systems installer"
print ""
print "📦 Installing nix-darwin..."
# Run darwin-rebuild from nix-darwin flake (uses master/unstable)
let flake_ref = "nix-darwin/master#darwin-rebuild"
let config_ref = "../nixos#malus"
^sudo ^nix run $flake_ref -- switch --flake $config_ref
print ""
print "✅ nix-darwin installed!"
print "💡 Future rebuilds: just darwin"

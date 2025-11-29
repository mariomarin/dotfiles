#!/usr/bin/env nu
# Unregister/remove NixOS from WSL

print "⚠️  WARNING: This will remove NixOS and all its data!"
print "Press Ctrl+C to cancel, or Enter to continue..."
input

print "🗑️  Unregistering NixOS from WSL..."
wsl --unregister NixOS

print "✅ NixOS unregistered from WSL"
print "💡 You can reinstall with: just import-nixos"

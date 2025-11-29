#!/usr/bin/env nu
# Set NixOS as default WSL distribution

print "⚙️  Setting NixOS as default WSL distribution..."
wsl --set-default NixOS
print "✅ NixOS is now the default WSL distribution"
print "💡 You can now use 'wsl' to start NixOS directly"

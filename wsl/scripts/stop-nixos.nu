#!/usr/bin/env nu
# Stop NixOS WSL instance

print "🛑 Stopping NixOS WSL..."
wsl --terminate NixOS
print "✅ NixOS WSL stopped"

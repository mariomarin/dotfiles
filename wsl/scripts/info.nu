#!/usr/bin/env nu
# Show WSL system information

print "ℹ️  WSL System Information"
print "========================="
print ""
wsl --status
print ""
print "NixOS Distribution Info:"
wsl -d NixOS --exec cat /etc/os-release

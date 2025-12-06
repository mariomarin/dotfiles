#!/usr/bin/env nu
# Test script for darwin hosts display

print "Available nix-darwin configurations:"
print $"  - malus : This Mac (detected via scutil)"
print ""
print $"Current HOST: malus"
print ""
print "To build for a different host:"
print "  just switch HOST=other-hostname"

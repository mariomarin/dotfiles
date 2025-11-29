#!/usr/bin/env nu
# Check if running on Windows

if (sys | get host.name) != "Windows" {
    print "❌ Error: WSL setup commands are only for Windows"
    print "   These commands help set up NixOS on WSL2 from Windows"
    exit 1
}

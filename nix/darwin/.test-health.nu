#!/usr/bin/env nu
# Test script for darwin health check

def run-cmd [cmd: closure] {
    let result = (do $cmd | complete)
    if $result.exit_code == 0 { $result.stdout | str trim } else { null }
}

print "🔍 nix-darwin Health Check"
print "=========================="

[
    ["Hostname",          (run-cmd {|| ^scutil --get LocalHostName} | default "unknown")]
    ["macOS version",     (run-cmd {|| ^sw_vers -productVersion}    | default "unknown")]
    ["Architecture",      (run-cmd {|| ^uname -m}                   | default "unknown")]
    ["Nix version",       (run-cmd {|| ^nix --version}              | default "not installed")]
    ["darwin-rebuild",    (if (which darwin-rebuild | is-not-empty) { "installed" } else { "❌ not installed" })]
    ["Flake exists",      (if ("../nixos/flake.nix" | path exists)  { "yes" }         else { "❌ no" })]
    ["nix-darwin config", (if ("/etc/nix-darwin" | path exists)     { "installed" }   else { "not installed (run: just first-time)" })]
]
| each {|row| print $"✓ ($row.0): ($row.1)"}

print ""

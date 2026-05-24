#!/usr/bin/env nu
# nix-darwin health check

def has-cmd [cmd: string]: nothing -> bool {
    (which $cmd | is-not-empty)
}

def check-nix []: nothing -> string {
    let result = (do { ^nix --version } | complete)
    if $result.exit_code == 0 { $result.stdout | str trim } else { "❌ not installed" }
}

print "nix-darwin Health Check"
print "======================="

[
    { label: "Nix",           value: (check-nix) }
    { label: "darwin-rebuild", value: (if (has-cmd "darwin-rebuild") { "installed" } else { "❌ not installed (run: just first-time)" }) }
    { label: "Flake",          value: (if ("../nixos/flake.nix" | path exists) { "yes" } else { "❌ missing" }) }
    { label: "nix-darwin",     value: (if ("/etc/nix-darwin" | path exists) { "configured" } else { "not configured (run: just first-time)" }) }
]
| each {|row| print $"  ($row.label): ($row.value)"}

print ""

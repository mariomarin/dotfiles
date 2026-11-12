#!/usr/bin/env nu
# Build nix/nixos packages for this system. `nix eval` never fetches sources,
# so only a build catches stale src/cargo/npm hashes.

def main [] {
    let flake = $env.FILE_PWD | path dirname | path join nix nixos
    let system = (nix eval --impure --raw --expr builtins.currentSystem)
    let names = (
        nix eval --json $"($flake)#packages.($system)" --apply builtins.attrNames
        | from json
    )
    nix build --no-link ...($names | each {|n| $"($flake)#($n)" })
}

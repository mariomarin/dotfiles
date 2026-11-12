#!/usr/bin/env nu
# Bump nix/nixos/pkgs to upstream (rev, src hash, cargo/npm/vendor hashes) via nix-update.
# Needs nix-update on PATH. tmux-tilish is excluded: pinned to a specific fork commit.

const PKGS = [
    [name, branch];
    [bitbucket-cli, false]
    [clipper, false]
    [jj-hooks, false]
    [jj-spr, true]
    [jj-stack, true]
    [tmux-harpoon, true]
]

def update [pkg: record]: nothing -> record {
    let version = if $pkg.branch { ["--version=branch"] } else { [] }
    let result = do { nix-update --flake ...$version $pkg.name } | complete
    {
        name: $pkg.name
        ok: ($result.exit_code == 0)
        stderr: $result.stderr
    }
}

def main [] {
    cd ($env.FILE_PWD | path dirname | path join nix nixos)
    let failed = $PKGS | each {|pkg| update $pkg } | where not ok
    if ($failed | is-empty) { return }
    $failed | each {|f| print -e $"❌ ($f.name)\n($f.stderr)" }
    exit 1
}

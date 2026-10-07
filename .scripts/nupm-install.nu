#!/usr/bin/env nu
# Install nutest + nupm registry packages.
# nupm and the nutest source are cloned by chezmoi (.chezmoiexternal.toml).
# Local modules (adt, bitwarden, ...) are plain Nushell modules deployed by
# chezmoi to ~/.config/nushell/modules, already on NU_LIB_DIRS — no nupm needed.

use adt.nu [ok, err, run-cmd]

# Same NUPM_HOME as env.nu. chezmoi runs this without env.nu, and nupm's own
# fallback (~/.config/nushell/nupm) is not on NU_LIB_DIRS.
def nupm-home []: nothing -> string {
    $env.NUPM_HOME? | default ($nu.home-dir | path join '.local' 'share' 'nupm')
}

def nupm [nupm_path: string, args: string]: nothing -> record {
    match (run-cmd { ^$nu.current-exe -c $"use ($nupm_path); nupm ($args)" }) {
        {ok: true} => (ok null)
        {error: $failure} => (err ($failure.stderr | str trim))
    }
}

def main [] {
    $env.NUPM_HOME = (nupm-home)
    let nupm_path = ($env.NUPM_HOME | path join 'nupm')
    if not ($nupm_path | path exists) {
        print -e $"nupm not found at ($nupm_path) — chezmoi external may not have cloned yet"
        exit 0
    }

    # Registry packages: best-effort, a registry fetch must not fail the apply
    match (nupm $nupm_path "install nu-scripts --force --no-confirm") {
        {ok: true} => null
        {error: $e} => (print -e $"registry install skipped: ($e)")
    }

    # nutest is not in the registry; install it from the chezmoi-managed clone
    let nutest_src = ($nu.home-dir | path join '.cache' 'nutest-src')
    if not ($nutest_src | path exists) { return }
    match (nupm $nupm_path $"install --path ($nutest_src) --force --no-confirm") {
        {ok: true} => null
        {error: $e} => (error make --unspanned {msg: $"nutest install failed: ($e)"})
    }
}

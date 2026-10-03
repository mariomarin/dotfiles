#!/usr/bin/env nu
# Install nutest + nupm registry packages.
# nupm and the nutest source are cloned by chezmoi (.chezmoiexternal.toml).
# Local modules (adt, bitwarden, ...) are plain Nushell modules deployed by
# chezmoi to ~/.config/nushell/modules, already on NU_LIB_DIRS — no nupm needed.

def install-module [nupm_path: string, module_path: string, name: string]: nothing -> bool {
    let result = do { ^nu -c $"use ($nupm_path); nupm install --path ($module_path) --force --no-confirm" } | complete
    if $result.exit_code != 0 {
        print -e $"failed: ($name)"
        print -e ($result.stderr | str trim)
    }
    $result.exit_code == 0
}

def main [] {
    let home = $env.HOME? | default $env.USERPROFILE?
    let nupm_path = $home | path join '.local' 'share' 'nupm' 'nupm'

    if not ($nupm_path | path exists) {
        print -e $"nupm not found at ($nupm_path) — chezmoi external may not have cloned yet"
        exit 0
    }

    # Registry packages (best-effort; don't fail the apply on a registry fetch)
    let reg = do { ^nu -c $"use ($nupm_path); nupm install nu-scripts --force --no-confirm" } | complete
    if $reg.exit_code != 0 { print -e $"registry install skipped: ($reg.stderr | str trim)" }

    # nutest — not in the registry, installed from the chezmoi-managed clone.
    let nutest_src = $home | path join '.cache' 'nutest-src'
    if ($nutest_src | path exists) {
        if not (install-module $nupm_path $nutest_src "nutest") {
            error make {msg: "nutest install failed"}
        }
    }
}

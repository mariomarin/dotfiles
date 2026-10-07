#!/usr/bin/env nu
# Doctor: report only problems with actionable fixes

use adt.nu [run-cmd]

# Missing command as {name, fix}, or null when it is on PATH
def check-cmd [cmd: string]: nothing -> any {
    match (which $cmd | where type == external) {
        [] => {name: $cmd, fix: "install it or check PATH"}
        _ => null
    }
}

def "main summary" [] {
    let issues = (
        ["chezmoi" "nvim" "tmux" "zsh" "nu"]
        | each {|cmd| check-cmd $cmd }
        | where {|r| $r != null }
    )

    if ($issues | is-empty) { return }

    $issues | each {|i| print $"  missing: ($i.name) — ($i.fix)" } | ignore
    exit 1
}

def "main all" [] {
    let components = [
        "nixos"
        "chezmoi"
        "nvim"
        "tmux"
        "zim"
        "kanata"
        "atuin"
    ]
    let failures = ($components | each {|c|
        match (run-cmd { ^just $"($c)-doctor" }) {
            {ok: true} => null
            {error: $failure} => {
                let out = ($failure.stdout | str trim)
                if ($out | is-not-empty) { print $out }
                $c
            }
        }
    } | compact)

    if ($failures | is-empty) {
        print "All good."
        return
    }

    exit 1
}

def main [] {
    main summary
}

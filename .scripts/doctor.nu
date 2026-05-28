#!/usr/bin/env nu
# Doctor: report only problems with actionable fixes

def check-cmd [cmd: string]: nothing -> record<name: string, fix: string> {
    let result = (do { ^sh -c $"command -v ($cmd)" } | complete)
    if $result.exit_code != 0 {
        { name: $cmd, fix: "install it or check PATH" }
    } else {
        null
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
    let components = ["nixos" "chezmoi" "nvim" "tmux" "zim" "kanata"]
    let failures = ($components | each {|c|
        let result = (do { ^just $"($c)-doctor" } | complete)
        if $result.exit_code != 0 {
            let out = ($result.stdout | str trim)
            if ($out | is-not-empty) { print $out }
            $c
        } else { null }
    } | where {|r| $r != null })

    if ($failures | is-empty) {
        print "All good."
        return
    }

    exit 1
}

def main [] {
    main summary
}

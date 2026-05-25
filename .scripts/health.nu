#!/usr/bin/env nu
# Health check utilities — reports only missing/broken tools

def check-cmd [cmd: string]: nothing -> record<name: string, ok: bool> {
    let result = (do { nu -c $cmd } | complete)
    { name: $cmd, ok: ($result.exit_code == 0) }
}

def evaluate-checks [results: list<record<name: string, ok: bool>>]: nothing -> record<ok: bool, missing: list<string>> {
    let missing = ($results | where {|r| not $r.ok } | get name)
    { ok: ($missing | is-empty), missing: $missing }
}

# Report missing/broken tools (silent when healthy)
def "main summary" [] {
    let checks = [
        (check-cmd "chezmoi --version")
        (check-cmd "nvim --version")
        (check-cmd "tmux -V")
        (check-cmd "zsh --version")
    ]

    let status = (evaluate-checks $checks)
    if $status.ok { return }

    print "Missing tools:"
    $status.missing | each {|m| print $"  ✗ ($m)" } | ignore
}

# Run component health checks, print only failures
def "main all" [] {
    let components = ["nixos-health" "chezmoi-health" "nvim-health" "tmux-health" "zim-health"]
    let failures = ($components | each {|c|
        let result = (do { just $c } | complete)
        if $result.exit_code != 0 { $c } else { null }
    } | where {|r| $r != null })

    if ($failures | is-empty) { return }

    print "Failed health checks:"
    $failures | each {|f| print $"  ✗ ($f)" } | ignore
}

def main [] {
    main summary
}

# Tests for health.nu
use std/assert

const SCRIPT = ".scripts/health.nu"

def "test script parses" [] {
    do { nu -n -c $"source ($SCRIPT)" } | complete | get exit_code | assert equal $in 0
}

def "test has subcommands" [] {
    let cmds = do { nu -n -c $"source ($SCRIPT); scope commands | where name =~ 'main' | get name" }
        | complete | get stdout | lines

    ["summary" "all"] | each { |sub|
        assert ($cmds | any { |c| $c =~ $sub }) $"missing ($sub) subcommand"
    } | ignore
}

def "test evaluate-checks all ok" [] {
    let result = do {
        nu -n -c 'source .scripts/health.nu; evaluate-checks [{name: "x", ok: true}, {name: "y", ok: true}] | to nuon'
    } | complete
    assert equal $result.exit_code 0
    let r = ($result.stdout | str trim | from nuon)
    assert equal $r.ok true
    assert equal ($r.missing | length) 0
}

def "test evaluate-checks reports missing" [] {
    let result = do {
        nu -n -c 'source .scripts/health.nu; evaluate-checks [{name: "a", ok: false}, {name: "b", ok: true}] | to nuon'
    } | complete
    assert equal $result.exit_code 0
    let r = ($result.stdout | str trim | from nuon)
    assert equal $r.ok false
    assert equal $r.missing ["a"]
}

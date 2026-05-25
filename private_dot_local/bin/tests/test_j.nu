# Tests for j (jj workflow helper)
use std/assert

const SCRIPT = "private_dot_local/bin/executable_j"

def "test script parses" [] {
    do { nu -n -c $"source ($SCRIPT)" } | complete | get exit_code | assert equal $in 0
}

def "test has subcommands" [] {
    let cmds = do {
        nu -n -c $"source ($SCRIPT); scope commands | where name =~ 'main' | get name | to nuon"
    } | complete | get stdout | str trim | from nuon

    ["main sync" "main land" "main pr" "main move" "main push" "main gp" "main spr" "main co" "main clean"]
    | each {|sub| assert ($cmds | any {|c| $c == $sub }) $"missing subcommand: ($sub)" }
    | ignore
}

def "test parse-bookmark-lines filters empty" [] {
    let result = do {
        nu -n -c 'source private_dot_local/bin/executable_j; ["feat-x" "" "fix-y"] | parse-bookmark-lines | to nuon'
    } | complete
    assert equal $result.exit_code 0
    let parsed = ($result.stdout | str trim | from nuon)
    assert equal ($parsed | length) 2
    assert equal ($parsed.0.value) "feat-x"
    assert equal ($parsed.1.value) "fix-y"
}

def "test parse-revision-lines" [] {
    let result = do {
        nu -n -c 'source private_dot_local/bin/executable_j; ["abc123 fix the thing" "def456 add feature" ""] | parse-revision-lines | to nuon'
    } | complete
    assert equal $result.exit_code 0
    let parsed = ($result.stdout | str trim | from nuon)
    assert equal ($parsed | length) 2
    assert equal ($parsed.0.value) "abc123"
    assert equal ($parsed.0.description) "fix the thing"
    assert equal ($parsed.1.value) "def456"
    assert equal ($parsed.1.description) "add feature"
}

def "test resolve-bookmark returns current when set" [] {
    let result = do {
        nu -n -c 'source private_dot_local/bin/executable_j; resolve-bookmark "my-branch" true "" | to nuon'
    } | complete
    assert equal $result.exit_code 0
    let r = ($result.stdout | str trim | from nuon)
    assert equal $r.ok true
    assert equal $r.value "my-branch"
}

def "test resolve-bookmark falls back to parent on empty commit" [] {
    let result = do {
        nu -n -c 'source private_dot_local/bin/executable_j; resolve-bookmark "" true "parent-bm" | to nuon'
    } | complete
    assert equal $result.exit_code 0
    let r = ($result.stdout | str trim | from nuon)
    assert equal $r.ok true
    assert equal $r.value "parent-bm"
}

def "test resolve-bookmark errors when commit has changes" [] {
    let result = do {
        nu -n -c 'source private_dot_local/bin/executable_j; resolve-bookmark "" false "parent-bm" | to nuon'
    } | complete
    assert equal $result.exit_code 0
    let r = ($result.stdout | str trim | from nuon)
    assert equal $r.ok false
    assert ($r.error | str contains "commit has changes")
}

def "test resolve-bookmark errors when nothing found" [] {
    let result = do {
        nu -n -c 'source private_dot_local/bin/executable_j; resolve-bookmark "" true "" | to nuon'
    } | complete
    assert equal $result.exit_code 0
    let r = ($result.stdout | str trim | from nuon)
    assert equal $r.ok false
    assert ($r.error | str contains "No bookmark found")
}

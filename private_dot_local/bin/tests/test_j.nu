# Tests for j (jj workflow helper)
use std/assert

# j imports its ADT helpers with `use adt.nu`, resolved relative to the script.
# In the deployed layout chezmoi puts adt.nu beside j; in-source it only exists
# as adt.nu.tmpl, so stage both into a tempdir to source j in isolation.
def with-j [body: closure] {
    let dir = (mktemp -d)
    cp private_dot_local/bin/executable_j $"($dir)/j"
    cp .scripts/adt.nu $"($dir)/adt.nu"
    let result = (do $body $"($dir)/j")
    rm -rf $dir
    $result
}

def "test script parses" [] {
    let result = with-j {|j| do { nu -n -c $"source ($j)" } | complete }
    assert equal $result.exit_code 0 $result.stderr
}

def "test has subcommands" [] {
    let cmds = with-j {|j|
        do { nu -n -c $"source ($j); scope commands | where name =~ 'main' | get name | to nuon" } | complete
    } | get stdout | str trim | from nuon

    [
        "main sync"
        "main land"
        "main pr"
        "main move"
        "main push"
        "main gp"
        "main spr"
        "main co"
        "main clean"
    ]
    | each {|sub| assert ($cmds | any {|c| $c == $sub }) $"missing subcommand: ($sub)" }
    | ignore
}

def "test parse-bookmark-lines filters empty" [] {
    let result = with-j {|j|
        let snippet = '["feat-x" "" "fix-y"] | parse-bookmark-lines | to nuon'
        do { nu -n -c $"source ($j); ($snippet)" } | complete
    }
    assert equal $result.exit_code 0
    let parsed = $result.stdout | str trim | from nuon
    assert equal ($parsed | length) 2
    assert equal ($parsed.0.value) "feat-x"
    assert equal ($parsed.1.value) "fix-y"
}

def "test parse-revision-lines" [] {
    let result = with-j {|j|
        let snippet = '["abc123 fix the thing" "def456 add feature" ""] | parse-revision-lines | to nuon'
        do { nu -n -c $"source ($j); ($snippet)" } | complete
    }
    assert equal $result.exit_code 0
    let parsed = $result.stdout | str trim | from nuon
    assert equal ($parsed | length) 2
    assert equal ($parsed.0.value) "abc123"
    assert equal ($parsed.0.description) "fix the thing"
    assert equal ($parsed.1.value) "def456"
    assert equal ($parsed.1.description) "add feature"
}

def "test resolve-bookmark returns current when set" [] {
    let result = with-j {|j|
        do { nu -n -c $"source ($j); resolve-bookmark \"my-branch\" true \"\" | to nuon" } | complete
    }
    assert equal $result.exit_code 0
    let r = $result.stdout | str trim | from nuon
    assert equal $r.ok true
    assert equal $r.value "my-branch"
}

def "test resolve-bookmark falls back to parent on empty commit" [] {
    let result = with-j {|j|
        do { nu -n -c $"source ($j); resolve-bookmark \"\" true \"parent-bm\" | to nuon" } | complete
    }
    assert equal $result.exit_code 0
    let r = $result.stdout | str trim | from nuon
    assert equal $r.ok true
    assert equal $r.value "parent-bm"
}

def "test resolve-bookmark errors when commit has changes" [] {
    let result = with-j {|j|
        do { nu -n -c $"source ($j); resolve-bookmark \"\" false \"parent-bm\" | to nuon" } | complete
    }
    assert equal $result.exit_code 0
    let r = $result.stdout | str trim | from nuon
    assert equal $r.ok false
    assert ($r.error | str contains "commit has changes")
}

def "test resolve-bookmark errors when nothing found" [] {
    let result = with-j {|j|
        do { nu -n -c $"source ($j); resolve-bookmark \"\" true \"\" | to nuon" } | complete
    }
    assert equal $result.exit_code 0
    let r = $result.stdout | str trim | from nuon
    assert equal $r.ok false
    assert ($r.error | str contains "No bookmark found")
}

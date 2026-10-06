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

# Evaluate a snippet with j sourced; returns the `complete` record
def j-eval [snippet: string]: nothing -> record {
    with-j {|j| do { nu -n -c $"source ($j); ($snippet)" } | complete }
}

def "test sync-scope defaults to all" [] {
    assert equal (j-eval 'sync-scope' | get stdout | str trim) "all()"
}

def "test sync-scope bookmark wins over flags" [] {
    assert equal (j-eval 'sync-scope feat --current --mine' | get stdout | str trim) "::(feat)"
}

def "test sync-scope current and mine" [] {
    assert equal (j-eval 'sync-scope --current' | get stdout | str trim) "::@"
    assert equal (j-eval 'sync-scope --mine' | get stdout | str trim) "mine()"
}

def "test local-work excludes immutable and base" [] {
    let r = (j-eval 'local-work "trunk()" "all()"' | get stdout | str trim)
    assert equal $r "(all()) & mutable() & ~::(trunk())"
}

def "test sync-roots avoids range operator" [] {
    let r = (j-eval 'sync-roots "trunk()" "W"' | get stdout | str trim)
    assert equal $r "roots(W) & children(::(trunk()))"
    # `base..x` pulls in immutable ancestors of x
    assert not ($r | str contains "..")
}

def "test run-or-fail returns stdout on success" [] {
    let r = (j-eval 'run-or-fail "Echo" { ^echo hi } | get stdout | str trim')
    assert equal ($r.stdout | str trim) "hi"
}

def "test run-or-fail raises labelled error" [] {
    let r = (j-eval 'run-or-fail "Boom" { ^false }')
    assert not equal $r.exit_code 0
    assert ($r.stderr | str contains "Boom failed")
}

def "test warn-err prints only on err" [] {
    assert equal (j-eval '{ok: true, value: {}} | warn-err "step"' | get stderr) ""
    let r = (j-eval '{ok: false, error: {stderr: "bad\n"}} | warn-err "step"')
    assert ($r.stderr | str contains "warning: step failed: bad")
}

# Run jj inside a repo dir; flags pass through untouched
def --wrapped jj-in [repo: string, ...args: string]: nothing -> record {
    do { cd $repo; ^jj ...$args } | complete
}

def exact [d: string]: nothing -> string { $"description\(exact:\"($d)\n\"\)" }

# Integration: sync must not touch immutable side branches (remote-only bookmarks)
def "test sync leaves stacks on immutable branches" [] {
    if (which jj | is-empty) { return }
    let repo = (mktemp -d)
    jj-in $repo git init . | ignore
    jj-in $repo config set --repo user.name t | ignore
    jj-in $repo config set --repo user.email t@t | ignore
    jj-in $repo config set --repo 'revset-aliases."trunk()"' 'present(main)' | ignore
    jj-in $repo config set --repo 'revset-aliases."immutable_heads()"' 'trunk() | present(side)' | ignore

    # A ── B(side, immutable) ── C
    #  ├── D            (moves)
    #  ├── E            (conflicts with A2 on f)
    #  ├── EMPTY        (abandoned)
    #  └── A2(main)
    jj-in $repo describe -m A | ignore; "a" | save $"($repo)/f"
    jj-in $repo new -m B | ignore; "b" | save $"($repo)/b"
    jj-in $repo bookmark create side -r @ | ignore
    jj-in $repo new -m C | ignore; "c" | save $"($repo)/c"
    jj-in $repo new (exact A) -m D | ignore; "d" | save $"($repo)/d"
    jj-in $repo new (exact A) -m E | ignore; "e" | save -f $"($repo)/f"
    jj-in $repo new (exact A) -m EMPTY | ignore
    jj-in $repo new (exact A) -m A2 | ignore; "a2" | save -f $"($repo)/f"
    jj-in $repo bookmark create main -r @ | ignore
    jj-in $repo new main | ignore

    let sync = with-j {|j| do { cd $repo; ^nu -n $j sync --no-pull } | complete }
    let parent = {|d| jj-in $repo log -r $"(exact $d)-" --no-graph -T 'description.first_line()' | get stdout }
    let state = {
        c: (do $parent C)
        d: (do $parent D)
        e_conflict: (jj-in $repo log -r $"(exact E) & conflicts\(\)" --no-graph -T '"y"' | get stdout)
        empty: (jj-in $repo log -r (exact EMPTY) --no-graph -T '"y"' | get stdout)
    }
    rm -rf $repo

    assert equal $sync.exit_code 0 $sync.stderr
    assert equal $state.c "B" "stack on immutable branch must stay put"
    assert equal $state.d "A2" "local work on old trunk must move"
    assert equal $state.e_conflict "y"
    assert equal $state.empty "" "empty commits are abandoned"
    assert ($sync.stderr | str contains "1 conflict(s)")
}

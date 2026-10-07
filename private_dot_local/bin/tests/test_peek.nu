# Tests for peek (open URL/file helper)
use std/assert

# peek imports adt.nu relative to itself; stage both like chezmoi deploys them
def with-peek [body: closure] {
    let dir = (mktemp -d)
    cp private_dot_local/bin/executable_peek $"($dir)/peek"
    cp .scripts/adt.nu $"($dir)/adt.nu"
    let result = (do $body $"($dir)/peek")
    rm -rf $dir
    $result
}

def peek-eval [snippet: string]: nothing -> any {
    let result = with-peek {|peek| do { nu -n -c $"source ($peek); ($snippet) | to nuon" } | complete }
    assert equal $result.exit_code 0 $result.stderr
    $result.stdout | str trim | from nuon
}

def "test script parses" [] {
    let result = with-peek {|peek| do { nu -n -c $"source ($peek)" } | complete }
    assert equal $result.exit_code 0 $result.stderr
}

def "test select-opener priority" [] {
    [
        [args expected];
        ["true true false" "nc"]
        ["false true false" "open"]
        ["false false true" "wslview"]
        ["false false false" "xdg-open"]
    ]
    | each {|case| assert equal (peek-eval $"select-opener ($case.args)") $case.expected }
    | ignore
}

def "test opener-argv" [] {
    assert equal (peek-eval "opener-argv nc [https://x]") [nc -w1 localhost "2226"]
    assert equal (peek-eval "opener-argv open [a b]") [/usr/bin/open a b]
    assert equal (peek-eval "opener-argv xdg-open [https://x]") [xdg-open https://x]
}

def "test is-ssh checks all ssh vars" [] {
    let result = with-peek {|peek|
        with-env {SSH_TTY: null, SSH_CONNECTION: "1.2.3.4 1 5.6.7.8 22", SSH_CLIENT: null} {
            do { nu -n -c $"source ($peek); is-ssh | to nuon" } | complete
        }
    }
    assert equal ($result.stdout | str trim) "true"
}

def "test run-opener reports nc failures with a hint" [] {
    # Port 1: nothing listens, so nc fails like a missing tunnel (and never
    # reaches a real xdg-open-svc on 2226)
    let r = peek-eval "run-opener [nc -w1 localhost 1] https://example.invalid"
    assert equal $r.ok false
    assert ($r.error | str contains "xdg-open-svc may not be running") $r.error
}

def "test run-opener reports missing openers" [] {
    let r = peek-eval "run-opener [peek-no-such-opener x] ''"
    assert equal $r.ok false
    assert ($r.error | str contains "peek-no-such-opener not found in PATH") $r.error
}

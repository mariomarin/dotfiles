# Tests for krew.nu
use std/assert
use helpers.nu [with-fake-bins]

const SCRIPT = ".scripts/krew.nu"

def "test script parses" [] {
    do { ^$nu.current-exe -n -c $"source ($SCRIPT)" } | complete | get exit_code | assert equal $in 0
}

def "test parse-krewfile filters comments and blanks" [] {
    let input = "# comment\nctx\nns\n\n# another\nindex/krew\noidc-login"
    let result = do {
        ^$nu.current-exe -n -c $"source .scripts/krew.nu; parse-krewfile '($input)' | to nuon"
    } | complete
    assert equal $result.exit_code 0
    let parsed = $result.stdout | str trim | from nuon
    assert equal $parsed ["ctx" "ns" "oidc-login"]
}

def "test parse-krewfile empty input" [] {
    let result = do {
        ^$nu.current-exe -n -c "source .scripts/krew.nu; parse-krewfile '' | to nuon"
    } | complete
    assert equal $result.exit_code 0
    assert equal ($result.stdout | str trim | from nuon) []
}

# Run krew.nu with a fake krew (fails for plugins named bad-*) and HOME
def with-fake-krew [krewfile: string, body: closure]: nothing -> record {
    let fake = 'case "$2" in bad-*) echo "no such plugin" >&2; exit 1;; esac'
    with-fake-bins {krew: $fake} {|home|
        let path = $home | path join .krewfile
        $krewfile | save $path
        let result = with-env {HOME: $home} { do $body }
        $result | insert krewfile (open --raw $path)
    }
}

def "test sync exits 1 and names failed plugins" [] {
    let r = with-fake-krew "ctx\nbad-one\nns\n" {
        do { nu -n $SCRIPT sync } | complete
    }
    assert equal $r.exit_code 1
    assert ($r.stderr | str contains "✗ bad-one: no such plugin") $r.stderr
    assert not ($r.stderr | str contains "ctx")
}

def "test sync succeeds quietly" [] {
    let r = with-fake-krew "ctx\nns\n" {
        do { nu -n $SCRIPT sync } | complete
    }
    assert equal $r.exit_code 0 $r.stderr
    assert equal $r.stderr ""
}

def "test install appends a plugin only once" [] {
    let r = with-fake-krew "ctx\n" {
        do {
            nu -n $SCRIPT install ctx
            nu -n $SCRIPT install ns
        } | complete
    }
    assert equal $r.exit_code 0 $r.stderr
    assert equal $r.krewfile "ctx\nns\n"
}

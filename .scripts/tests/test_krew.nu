# Tests for krew.nu
use std/assert

const SCRIPT = ".scripts/krew.nu"

def "test script parses" [] {
    do { nu -n -c $"source ($SCRIPT)" } | complete | get exit_code | assert equal $in 0
}

def "test parse-krewfile filters comments and blanks" [] {
    let input = "# comment\nctx\nns\n\n# another\nindex/krew\noidc-login"
    let result = do {
        nu -n -c $"source .scripts/krew.nu; parse-krewfile '($input)' | to nuon"
    } | complete
    assert equal $result.exit_code 0
    let parsed = $result.stdout | str trim | from nuon
    assert equal $parsed ["ctx" "ns" "oidc-login"]
}

def "test parse-krewfile empty input" [] {
    let result = do {
        nu -n -c "source .scripts/krew.nu; parse-krewfile '' | to nuon"
    } | complete
    assert equal $result.exit_code 0
    assert equal ($result.stdout | str trim | from nuon) []
}

# Run krew.nu with a fake krew (fails for plugins named bad-*) and HOME
def with-fake-krew [krewfile: string, body: closure]: nothing -> record {
    let home = (mktemp -d)
    let bin = $"($home)/bin"
    mkdir $bin
    "#!/bin/sh\ncase \"$2\" in bad-*) echo \"no such plugin\" >&2; exit 1;; esac\n" | save $"($bin)/krew"
    ^chmod +x $"($bin)/krew"
    $krewfile | save $"($home)/.krewfile"
    let result = with-env {HOME: $home, PATH: ($env.PATH | prepend $bin)} { do $body }
    let after = (open --raw $"($home)/.krewfile")
    rm -rf $home
    $result | insert krewfile $after
}

def "test sync exits 1 and names failed plugins" [] {
    let r = with-fake-krew "ctx\nbad-one\nns\n" { do { nu -n $SCRIPT sync } | complete }
    assert equal $r.exit_code 1
    assert ($r.stderr | str contains "✗ bad-one: no such plugin") $r.stderr
    assert not ($r.stderr | str contains "ctx")
}

def "test sync succeeds quietly" [] {
    let r = with-fake-krew "ctx\nns\n" { do { nu -n $SCRIPT sync } | complete }
    assert equal $r.exit_code 0 $r.stderr
    assert equal $r.stderr ""
}

def "test install appends a plugin only once" [] {
    let r = with-fake-krew "ctx\n" { do { nu -n $SCRIPT install ctx; nu -n $SCRIPT install ns } | complete }
    assert equal $r.exit_code 0 $r.stderr
    assert equal $r.krewfile "ctx\nns\n"
}

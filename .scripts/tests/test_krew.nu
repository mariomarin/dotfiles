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
    let parsed = ($result.stdout | str trim | from nuon)
    assert equal $parsed ["ctx" "ns" "oidc-login"]
}

def "test parse-krewfile empty input" [] {
    let result = do {
        nu -n -c "source .scripts/krew.nu; parse-krewfile '' | to nuon"
    } | complete
    assert equal $result.exit_code 0
    assert equal ($result.stdout | str trim | from nuon) []
}

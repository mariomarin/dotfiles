# Tests for tridactyl-native.nu
use std/assert

const SCRIPT = ".scripts/tridactyl-native.nu"

def "test script parses" [] {
    do { nu -n -c $"source ($SCRIPT)" } | complete | get exit_code | assert equal $in 0
}

def "test build-manifest structure" [] {
    let result = do {
        nu -n -c 'source .scripts/tridactyl-native.nu; build-manifest "/nix/store/abc/bin/native_main" | to nuon'
    } | complete
    assert equal $result.exit_code 0
    let m = ($result.stdout | str trim | from nuon)
    assert equal $m.name "tridactyl"
    assert equal $m.type "stdio"
    assert equal $m.path "/nix/store/abc/bin/native_main"
    assert equal ($m.allowed_extensions | length) 3
}

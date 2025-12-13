# Bitwarden module tests
use std/assert

const MOD = "private_dot_config/nushell/modules/bitwarden/mod.nu"

def "test module parses" [] {
    do { nu -n -c $"source ($MOD)" } | complete | get exit_code | assert equal $in 0
}

def "test session file operations" [] {
    let test_dir = mktemp -d
    cd $test_dir

    let token = "test-session-12345"
    $"BW_SESSION=($token)" | save -f .env.local

    assert (".env.local" | path exists)
    open .env.local | str replace "BW_SESSION=" "" | str trim | assert equal $in $token

    rm -rf $test_dir
}

# Bitwarden module tests
use std/assert

def "test module loads" [] {
    do { nu -n -c "use ../mod.nu" } | complete | get exit_code | assert equal $in 0
}

def "test help output" [] {
    let help = nu -n -c "use ../mod.nu; bitwarden help" | str downcase
    ["unlock" "reload" "get item" "status"]
    | each { |cmd| assert str contains $help $cmd }
    | ignore
}

def "test session storage" [] {
    let test_dir = mktemp -d
    cd $test_dir

    let token = "test-session-token-12345"
    $"BW_SESSION=($token)" | save -f .env.local

    assert (".env.local" | path exists)

    open .env.local
    | str replace "BW_SESSION=" ""
    | str trim
    | assert equal $in $token

    rm -rf $test_dir
}

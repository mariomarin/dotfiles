# Claude-helpers module tests
use std/assert

def "test module loads" [] {
    do { nu -n -c "use ../mod.nu" } | complete | get exit_code | assert equal $in 0
}

def "test help output" [] {
    let help = nu -n -c "use ../mod.nu; claude help" | str downcase
    ["cl" "improve" "popus" "dopus" "copus" "claudepool"]
    | each { |cmd| assert str contains $help $cmd }
    | ignore
}

def "test exports exist" [] {
    nu -n -c "use ../mod.nu; scope commands | where name in [cl improve popus dopus copus claudepool ccusage] | length"
    | into int
    | assert ($in >= 5) "should export claude helper commands"
}

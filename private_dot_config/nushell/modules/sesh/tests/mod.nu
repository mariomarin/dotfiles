# Sesh module tests
use std/assert

def "test module loads" [] {
    do { nu -n -c "use ../mod.nu" } | complete | get exit_code | assert equal $in 0
}

def "test exports exist" [] {
    nu -n -c "use ../mod.nu; scope commands | where name =~ sesh | length"
    | into int
    | assert ($in > 0) "should export sesh commands"
}

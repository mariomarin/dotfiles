# Tests for peek (open URL/file helper)
use std/assert

const SCRIPT = "private_dot_local/bin/executable_peek"

def "test script parses" [] {
    do { nu -n -c $"source ($SCRIPT)" } | complete | get exit_code | assert equal $in 0
}

def "test select-opener ssh priority" [] {
    let result = do {
        nu -n -c 'source private_dot_local/bin/executable_peek; select-opener true true false'
    } | complete
    assert equal ($result.stdout | str trim) "nc"
}

def "test select-opener macos" [] {
    let result = do {
        nu -n -c 'source private_dot_local/bin/executable_peek; select-opener false true false'
    } | complete
    assert equal ($result.stdout | str trim) "open"
}

def "test select-opener wsl" [] {
    let result = do {
        nu -n -c 'source private_dot_local/bin/executable_peek; select-opener false false true'
    } | complete
    assert equal ($result.stdout | str trim) "wslview"
}

def "test select-opener linux" [] {
    let result = do {
        nu -n -c 'source private_dot_local/bin/executable_peek; select-opener false false false'
    } | complete
    assert equal ($result.stdout | str trim) "xdg-open"
}

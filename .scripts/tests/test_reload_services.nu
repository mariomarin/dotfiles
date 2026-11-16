# Tests for reload-services.nu
use std/assert

const SCRIPT = ".scripts/reload-services.nu"

def "test script parses" []: nothing -> nothing {
    do { ^$nu.current-exe -n -c $"source ($SCRIPT)" } | complete | get exit_code | assert equal $in 0
}

def "test has-changed detects new service" []: nothing -> nothing {
    let test_script = $"
        source ($SCRIPT)
        has-changed 'kanata' 'newhash' {} | to nuon
    "
    let result = ^$nu.current-exe -n -c $test_script | str trim | from nuon
    assert equal $result true
}

def "test has-changed detects changed hash" []: nothing -> nothing {
    let test_script = $"
        source ($SCRIPT)
        has-changed 'kanata' 'newhash' { kanata: 'oldhash' } | to nuon
    "
    let result = ^$nu.current-exe -n -c $test_script | str trim | from nuon
    assert equal $result true
}

def "test has-changed returns false for same hash" []: nothing -> nothing {
    let test_script = $"
        source ($SCRIPT)
        has-changed 'kanata' 'samehash' { kanata: 'samehash' } | to nuon
    "
    let result = ^$nu.current-exe -n -c $test_script | str trim | from nuon
    assert equal $result false
}

def "test is-running-pgrep returns false for nonexistent process" []: nothing -> nothing {
    let test_script = $"
        source ($SCRIPT)
        is-running-pgrep 'nonexistent_process_xyz123' | to nuon
    "
    let result = ^$nu.current-exe -n -c $test_script | str trim | from nuon
    assert equal $result false
}

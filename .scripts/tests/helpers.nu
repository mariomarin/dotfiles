#!/usr/bin/env nu
# Test helpers and property-based testing utilities

use std assert

# Test runner that captures exceptions
export def test-case [name: string, test: closure]: nothing -> record {
    try {
        do $test
        {name: $name, result: "pass", error: null}
    } catch {|e|
        {name: $name, result: "fail", error: $e}
    }
}

# Property-based testing: check property holds for all generated values
export def check-property [
    property: closure
    generator: closure
    --count: int = 100
]: nothing -> record {
    let failures = (1..$count
        | each {|| do $generator}
        | where {|val| not (do $property $val)}
    )

    if ($failures | is-empty) {
        {passed: true, failures: []}
    } else {
        {passed: false, failures: $failures}
    }
}

# Generators for property-based testing
export def gen-int [--min: int = 0, --max: int = 100]: nothing -> int {
    random int $min..$max
}

export def gen-string [--length: int = 10]: nothing -> string {
    random chars --length $length
}

export def gen-list [
    element_gen: closure
    --size: int = 10
]: nothing -> list {
    1..$size | each {|| do $element_gen}
}

export def gen-bool []: nothing -> bool {
    (random int 0..1) == 1
}

# Assertion helpers with better error messages
export def assert-ok [result: record]: nothing -> nothing {
    assert ($result.ok? == true) $"Expected ok, got: ($result | to json)"
}

export def assert-err [result: record]: nothing -> nothing {
    assert ($result.ok? == false) $"Expected err, got: ($result | to json)"
}

export def assert-valid [validation: record]: nothing -> nothing {
    assert ($validation.valid? == true) $"Expected valid, got: ($validation | to json)"
}

export def assert-invalid [validation: record]: nothing -> nothing {
    assert ($validation.valid? == false) $"Expected invalid, got: ($validation | to json)"
}

export def assert-contains [haystack: any, needle: any]: nothing -> nothing {
    assert ($haystack | str contains $needle) $"Expected '($haystack)' to contain '($needle)'"
}

export def assert-length [list: list, expected: int]: nothing -> nothing {
    let actual = ($list | length)
    assert ($actual == $expected) $"Expected length ($expected), got ($actual)"
}

# Snapshot testing helper
export def snapshot [name: string, value: any]: nothing -> nothing {
    let snapshot_dir = ".scripts/tests/snapshots"
    mkdir $snapshot_dir
    let snapshot_file = $"($snapshot_dir)/($name).json"

    if ($snapshot_file | path exists) {
        let expected = (open $snapshot_file)
        assert ($value == $expected) $"Snapshot mismatch for ($name)"
    } else {
        $value | save $snapshot_file
        print $"Created snapshot: ($snapshot_file)"
    }
}

# Mock command execution for testing
export def mock-cmd [
    expected_exit: int = 0
    expected_stdout: string = ""
    expected_stderr: string = ""
]: nothing -> record {
    {
        exit_code: $expected_exit
        stdout: $expected_stdout
        stderr: $expected_stderr
    }
}

# Run all test functions in a module
export def run-tests []: nothing -> table {
    let test_functions = (
        scope commands
        | where name =~ '^test '
        | get name
    )

    $test_functions
    | each {|test_name|
        test-case $test_name {|| (do $test_name)}
    }
}

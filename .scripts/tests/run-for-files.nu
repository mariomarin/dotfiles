#!/usr/bin/env nu
# Run tests for specific changed files
# Usage: nu run-for-files.nu file1.nu file2.nu ...

use std/assert
use run-nutest.nu run-suites

def get-test-funcs [test_file: string]: nothing -> list<string> {
    # Fresh interpreter per file: source needs a parse-time path
    let result = do {
        ^$nu.current-exe -n -c $"source ($test_file); scope commands | where name =~ '^test ' | get name | to nuon"
    } | complete
    if $result.exit_code != 0 { return [] }
    try { $result.stdout | str trim | from nuon } catch { [] }
}

def run-test [test_file: string, func: string]: nothing -> record<name: string, passed: bool, error: string> {
    let result = do { ^$nu.current-exe -n -c $"source ($test_file); ($func)" } | complete
    {
        name: $func
        passed: ($result.exit_code == 0)
        error: ($result.stderr | str trim)
    }
}

def run-test-file [test_file: string]: nothing -> list<record> {
    # Module suites are nutest (@test attributes), the rest `test …` commands
    if $test_file =~ modules/ { return (run-suites ($test_file | path dirname)) }
    get-test-funcs $test_file | each {|func| run-test $test_file $func }
}

# Map source file to its test file(s)
def find-tests [source_file: string]: nothing -> list<string> {
    let name = $source_file | path basename | str replace ".nu" "" | str replace --all "-" "_"
    let dir = $source_file | path dirname

    # .scripts/*.nu → .scripts/tests/test_*.nu
    if ($dir | str ends-with ".scripts") {
        let test = $".scripts/tests/test_($name).nu"
        if ($test | path exists) { return [$test] }
        return [".scripts/tests/test_all_scripts.nu"]
    }

    # private_dot_local/bin/* → private_dot_local/bin/tests/test_*.nu
    if ($dir | str ends-with "private_dot_local/bin") {
        let bin_name = $name | str replace "executable_" ""
        let test = $"private_dot_local/bin/tests/test_($bin_name).nu"
        if ($test | path exists) { return [$test] }
    }

    # modules/*/mod.nu → modules/*/tests/test_*.nu (nutest)
    if $source_file =~ modules/ and ($dir | path basename) != "tests" {
        return (glob $"($dir)/tests/test_*.nu")
    }

    []
}

def main [
    ...files: string # Changed files to run tests for
]: nothing -> nothing {
    let tests_to_run = $files
    | where {|f| $f | str ends-with ".nu" }
    | where {|f| $f !~ /tests/ }
    | each {|f| find-tests $f }
    | flatten
    | uniq

    if ($tests_to_run | is-empty) {
        print "No tests to run"
        exit 0
    }

    print $"🧪 Running tests for changed files..."

    let results = $tests_to_run | each {|t|
        print $"📁 ($t)"
        run-test-file $t | each {|r|
            let icon = if $r.passed { "✅" } else { "❌" }
            print $"   ($icon) ($r.name)"
            if not $r.passed { print $"      ($r.error)" }
            $r
        }
    } | flatten

    let passed = $results | where passed | length
    let total = $results | length

    print $"📊 ($passed)/($total) passed"
    if $passed < $total { exit 1 }
}

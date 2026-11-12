#!/usr/bin/env nu
# Run tests for specific changed files
# Usage: nu run-for-files.nu file1.nu file2.nu ...

use std/assert
use run-nutest.nu run-suites
use run-lib.nu [run-file]

def run-test-file [test_file: string]: nothing -> list<record> {

    # Module suites are nutest (@test attributes), the rest `test …` commands
    if $test_file =~ modules/ { return (run-suites ($test_file | path dirname)) }
    run-file $test_file
}

# Map a changed file to its test file(s); test files map to themselves
def find-tests [source_file: string]: nothing -> list<string> {
    let dir = $source_file | path dirname
    let base = $source_file | path basename
    if ($dir | path basename) == "tests" {
        return (if $base starts-with "test_" { [$source_file] } else { [] })
    }

    # modules/*/mod.nu → modules/*/tests/test_*.nu (nutest)
    if $source_file =~ modules/ { return (glob $"($dir)/tests/test_*.nu") }

    # foo-bar.nu or executable_foo-bar → <dir>/tests/ or .scripts/tests/test_foo_bar.nu
    let name = $base | str replace --regex '\.nu$' "" | str replace --regex '^executable_' "" | str replace --all "-" "_"
    let found = [$"($dir)/tests/test_($name).nu" $".scripts/tests/test_($name).nu"] | where {|t| $t | path exists }
    if ($found | is-not-empty) { return ($found | first 1) }
    if ($dir | str ends-with ".scripts") { return [".scripts/tests/test_all_scripts.nu"] }
    []
}

def main [
    ...files: string # Changed files to run tests for
]: nothing -> nothing {
    let tests_to_run = $files
    | where {|f| ($f | str ends-with ".nu") or ($f | path basename | str starts-with "executable_") }
    | each {|f| find-tests $f }
    | flatten
    | path expand
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

#!/usr/bin/env nu
# Run tests for specific changed files
# Usage: nu run-for-files.nu file1.nu file2.nu ...

use std/assert

def get-test-funcs [test_file: string] {
    let result = do {
        nu -n -c $"source ($test_file); scope commands | where name =~ '^test ' | get name | to nuon"
    } | complete
    if $result.exit_code != 0 { return [] }
    $result.stdout | str trim | from nuon
}

def run-test [test_file: string, func: string] {
    let result = do { nu -n -c $"source ($test_file); ($func)" } | complete
    { name: $func, passed: ($result.exit_code == 0), error: ($result.stderr | str trim) }
}

def run-test-file [test_file: string] {
    get-test-funcs $test_file | each { |func| run-test $test_file $func }
}

# Map source file to its test file(s)
def find-tests [source_file: string] {
    let name = $source_file | path basename | str replace ".nu" "" | str replace "-" "_"
    let dir = $source_file | path dirname

    # .scripts/*.nu → .scripts/tests/test_*.nu
    if ($dir | str ends-with ".scripts") {
        let test = $".scripts/tests/test_($name).nu"
        if ($test | path exists) { return [$test] }
        return [".scripts/tests/test_all_scripts.nu"]
    }

    # modules/*/mod.nu → modules/*/tests/mod.nu
    if ($source_file | str contains "modules/") and ($dir | path basename) != "tests" {
        let module_dir = if ($name == "mod") { $dir } else { $dir }
        let test = $"($module_dir)/tests/mod.nu"
        if ($test | path exists) { return [$test] }
    }

    []
}

def main [...files: string] {
    let tests_to_run = $files
        | where { |f| $f | str ends-with ".nu" }
        | where { |f| not ($f | str contains "/tests/") }
        | each { |f| find-tests $f }
        | flatten
        | uniq

    if ($tests_to_run | is-empty) {
        print "No tests to run"
        exit 0
    }

    print $"🧪 Running tests for changed files..."

    let results = $tests_to_run | each { |t|
        print $"📁 ($t)"
        run-test-file $t | each { |r|
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

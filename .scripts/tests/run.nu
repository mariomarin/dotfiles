#!/usr/bin/env nu
# Test runner for .scripts/*.nu files

use std/assert
use run-nutest.nu run-suites
use ../adt.nu [run-cmd "result map"]

# Result of the file's "test ..." command names; err when it fails to parse
def load-test-funcs [test_file: string]: nothing -> record {
    run-cmd {
        ^$nu.current-exe -n -c $"source ($test_file); scope commands | where name =~ '^test ' | get name | to nuon"
    }
    | result map {|out| $out.stdout | str trim | from nuon }
}

# Run each "test ..." command in a file; a parse failure is one failed result
def run-file [test_file: string]: nothing -> list<record> {
    let loaded = load-test-funcs $test_file
    if not $loaded.ok {
        return [
            {
                name: "load file"
                passed: false
                error: ($loaded.error.stderr | str trim)
            }
        ]
    }
    $loaded.value | each {|func| run-test $test_file $func }
}

def run-test [test_file: string, func: string] {
    let result = do { ^$nu.current-exe -n -c $"source ($test_file); ($func)" } | complete
    {
        name: $func
        passed: ($result.exit_code == 0)
        error: ($result.stderr | str trim)
    }
}

def main [] {
    print "🧪 Running all Nushell tests..."
    print ""

    let test_dirs = [
        ".scripts/tests/*.nu"
        "private_dot_local/bin/tests/*.nu"
        "nix/darwin/tests/*.nu"
        "nix/nixos/tests/*.nu"
    ]

    let results = $test_dirs
    | each {|pattern| glob $pattern }
    | flatten
    | where {|f| ($f | path basename) !~ '^run'}
    | each { |f|
            print $"📁 ($f)"
            run-file $f | each {|r|
                let icon = if $r.passed { "✅" } else { "❌" }
                print $"   ($icon) ($r.name)"
                if not $r.passed { print $"      ($r.error)" }
                $r
            }
        }
    | flatten
    | append (
        glob "private_dot_config/nushell/modules/*/tests/test_*.nu"
        | each {|f| $f | path dirname } | uniq
        | each {|dir|
            print $"📁 ($dir) \(nutest\)"
            run-suites $dir | each {|r|
                let icon = if $r.passed { "✅" } else { "❌" }
                print $"   ($icon) ($r.name)"
                if not $r.passed { print $"      ($r.error)" }
                $r
            }
        }
        | flatten
    )

    let passed = $results | where passed | length
    let total = $results | length

    print ""
    print $"📊 Results: ($passed)/($total) passed"

    if $passed < $total { exit 1 }
}

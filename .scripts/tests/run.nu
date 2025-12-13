#!/usr/bin/env nu
# Test runner for .scripts/*.nu files

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
    {
        name: $func
        passed: ($result.exit_code == 0)
        error: ($result.stderr | str trim)
    }
}

def main [] {
    print "🧪 Running .scripts tests..."
    print ""

    let results = glob ".scripts/tests/test_*.nu"
        | each { |f|
            print $"📁 ($f)"
            let funcs = get-test-funcs $f
            $funcs | each { |func|
                let r = run-test $f $func
                let icon = if $r.passed { "✅" } else { "❌" }
                print $"   ($icon) ($r.name)"
                if not $r.passed { print $"      ($r.error)" }
                $r
            }
        }
        | flatten

    let passed = $results | where passed | length
    let total = $results | length

    print ""
    print $"📊 Results: ($passed)/($total) passed"

    if $passed < $total { exit 1 }
}

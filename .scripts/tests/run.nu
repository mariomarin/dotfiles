#!/usr/bin/env nu
# Test runner for .scripts/*.nu files

use std/assert
use run-nutest.nu run-suites
use run-lib.nu [run-file]

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

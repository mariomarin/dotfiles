#!/usr/bin/env nu
# Run all test suites and report results

def main [] {
    let test_files = [
        ".scripts/tests/test_adt.nu"
        ".scripts/tests/test_kanata_doctor.nu"
        ".scripts/tests/test_integration.nu"
    ]

    print "=== Running Test Suite ==="
    print ""

    let results = ($test_files | each {|file|
        print $"Running ($file)..."
        let result = (do { nu $file } | complete)

        if $result.exit_code == 0 {
            {file: $file, status: "PASS"}
        } else {
            {file: $file, status: "FAIL", error: $result.stderr}
        }
    })

    print ""
    print "=== Test Summary ==="
    $results | each {|r|
        if $r.status == "PASS" {
            print $"✓ ($r.file)"
        } else {
            print $"✗ ($r.file)"
            if ($r.error? | is-not-empty) {
                print $"  ($r.error | lines | first)"
            }
        }
    }

    let failed = ($results | where status == "FAIL" | length)
    let total = ($results | length)
    let passed = $total - $failed

    print ""
    print $"Results: ($passed)/($total) passed"

    if $failed > 0 {
        exit 1
    }
}

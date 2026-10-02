#!/usr/bin/env nu
use std assert
use ../adt.nu *

# --- Result ADT tests ---

export def "test ok creates success result" [] {
    let result = (ok "value")
    assert ($result | is-ok)
    assert ($result.value == "value")
}

export def "test err creates error result" [] {
    let result = (err "error message")
    assert ($result | is-err)
    assert ($result.error == "error message")
}

export def "test is-ok detects success" [] {
    assert ((ok "test") | is-ok)
    assert (not ((err "test") | is-ok))
}

export def "test is-err detects error" [] {
    assert ((err "test") | is-err)
    assert (not ((ok "test") | is-err))
}

export def "test result map transforms success value" [] {
    let result = (ok 5 | result map {|x| $x + 1})
    assert ($result | is-ok)
    assert ($result.value == 6)
}

export def "test result map leaves error unchanged" [] {
    let result = (err "fail" | result map {|x| $x + 1})
    assert ($result | is-err)
    assert ($result.error == "fail")
}

export def "test result unwrap-or returns value on success" [] {
    let val = (ok 42 | result unwrap-or 0)
    assert ($val == 42)
}

export def "test result unwrap-or returns default on error" [] {
    let val = (err "fail" | result unwrap-or 0)
    assert ($val == 0)
}

export def "test run-cmd success" [] {
    let result = (run-cmd {echo "test"})
    assert ($result | is-ok)
    assert ($result.value.stdout | str contains "test")
}

export def "test run-cmd failure" [] {
    let result = (run-cmd {false})
    assert ($result | is-err)
    assert ($result.error.code != 0)
}

# --- Validation ADT tests ---

export def "test valid creates success validation" [] {
    let result = (valid "value")
    assert ($result | is-valid)
    assert ($result.value == "value")
}

export def "test invalid creates error validation" [] {
    let result = (invalid ["error1" "error2"])
    assert ($result | is-invalid)
    assert (($result.errors | length) == 2)
}

export def "test is-valid detects success" [] {
    assert ((valid "test") | is-valid)
    assert (not ((invalid ["test"]) | is-valid))
}

export def "test is-invalid detects error" [] {
    assert ((invalid ["test"]) | is-invalid)
    assert (not ((valid "test") | is-invalid))
}

export def "test collect-issues accumulates all issues" [] {
    let checks = [
        {|| ["issue1"]}
        {|| ["issue2" "issue3"]}
        {|| []}
    ]
    let issues = (null | collect-issues $checks)
    assert (($issues | length) == 3)
    assert (($issues | get 0) == "issue1")
}

export def "test collect-issues filters nulls and empty" [] {
    let checks = [
        {|| ["issue1"]}
        {|| [null]}
        {|| []}
        {|| ["issue2"]}
    ]
    let issues = (null | collect-issues $checks)
    assert (($issues | length) == 2)
}

export def "test validation combine accumulates errors" [] {
    let validators = [
        {|x| if $x > 0 {valid $x} else {invalid ["must be positive"]}}
        {|x| if $x < 100 {valid $x} else {invalid ["must be less than 100"]}}
    ]
    let result = (-5 | validation combine $validators)
    assert ($result | is-invalid)
    assert ($result.errors | str contains "must be positive")
}

export def "test validation combine succeeds when all valid" [] {
    let validators = [
        {|x| if $x > 0 {valid $x} else {invalid ["must be positive"]}}
        {|x| if $x < 100 {valid $x} else {invalid ["must be less than 100"]}}
    ]
    let result = (50 | validation combine $validators)
    assert ($result | is-valid)
    assert ($result.value == 50)
}

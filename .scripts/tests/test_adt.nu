#!/usr/bin/env nu
use std assert
use ../adt.nu *
use helpers.nu *

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

# --- New combinator tests ---

export def "test result flat-map chains computations" [] {
    let divide = {|x| if $x != 0 {ok (10 / $x)} else {err "division by zero"}}

    let result1 = (ok 2 | result flat-map $divide)
    assert ($result1 | is-ok)
    assert ($result1.value == 5)

    let result2 = (ok 0 | result flat-map $divide)
    assert ($result2 | is-err)
}

export def "test result flat-map short-circuits on error" [] {
    let should_not_run = {|_| ok "should not see this"}
    let result = (err "initial error" | result flat-map $should_not_run)
    assert ($result | is-err)
    assert ($result.error == "initial error")
}

export def "test result bimap transforms both paths" [] {
    let double = {|x| $x * 2}
    let uppercase = {|s| $s | str uppercase}

    let result1 = (ok 5 | result bimap $double $uppercase)
    assert ($result1 | is-ok)
    assert ($result1.value == 10)

    let result2 = (err "error" | result bimap $double $uppercase)
    assert ($result2 | is-err)
    assert ($result2.error == "ERROR")
}

export def "test result sequence all succeed" [] {
    let results = [(ok 1) (ok 2) (ok 3)]
    let sequenced = ($results | result sequence)
    assert ($sequenced | is-ok)
    assert ($sequenced.value == [1 2 3])
}

export def "test result sequence fails if any fail" [] {
    let results = [(ok 1) (err "failed") (ok 3)]
    let sequenced = ($results | result sequence)
    assert ($sequenced | is-err)
}

export def "test result try catches errors" [] {
    let safe_divide = {|x| 10 / $x}

    let result1 = (2 | result try $safe_divide)
    assert ($result1 | is-ok)

    let result2 = (0 | result try $safe_divide)
    assert ($result2 | is-err)
}

export def "test validation map transforms valid value" [] {
    let result = (valid 5 | validation map {|x| $x * 2})
    assert ($result | is-valid)
    assert ($result.value == 10)
}

export def "test validation map preserves invalid" [] {
    let result = (invalid ["error"] | validation map {|x| $x * 2})
    assert ($result | is-invalid)
    assert ($result.errors == ["error"])
}

export def "test validation recover provides fallback" [] {
    assert ((valid 42 | validation recover 0) == 42)
    assert ((invalid ["error"] | validation recover 0) == 0)
}

export def "test either type left and right" [] {
    let l = (left "error")
    assert ($l | is-left)
    assert (not ($l | is-right))

    let r = (right 42)
    assert ($r | is-right)
    assert (not ($r | is-left))
}

# --- Property-based tests ---

export def "test property result map preserves ok-ness" [] {
    let prop = {|x|
        let result = (ok $x | result map {|v| $v + 1})
        $result | is-ok
    }
    let check = (check-property $prop {|| gen-int} --count 50)
    assert ($check.passed)
}

export def "test property result unwrap-or always returns value" [] {
    let prop = {|x|
        let result = if ($x mod 2 == 0) {ok $x} else {err "odd"}
        let value = ($result | result unwrap-or 0)
        $value >= 0
    }
    let check = (check-property $prop {|| gen-int} --count 50)
    assert ($check.passed)
}

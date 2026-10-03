# nutest suite for the adt module
# SPIKE: imports adt by BARE NAME to test NU_LIB_DIRS resolution inside nutest.
# Self-contained: property checks use native `random int`, no helpers.nu.
use std assert
use std/testing *
use adt *

# --- Result ADT tests ---

@test
def "ok creates success result" [] {
    let result = (ok "value")
    assert ($result | is-ok)
    assert ($result.value == "value")
}

@test
def "err creates error result" [] {
    let result = (err "error message")
    assert ($result | is-err)
    assert ($result.error == "error message")
}

@test
def "is-ok detects success" [] {
    assert ((ok "test") | is-ok)
    assert (not ((err "test") | is-ok))
}

@test
def "is-err detects error" [] {
    assert ((err "test") | is-err)
    assert (not ((ok "test") | is-err))
}

@test
def "result map transforms success value" [] {
    let result = (ok 5 | result map {|x| $x + 1})
    assert ($result | is-ok)
    assert ($result.value == 6)
}

@test
def "result map leaves error unchanged" [] {
    let result = (err "fail" | result map {|x| $x + 1})
    assert ($result | is-err)
    assert ($result.error == "fail")
}

@test
def "result unwrap-or returns value on success" [] {
    let val = (ok 42 | result unwrap-or 0)
    assert ($val == 42)
}

@test
def "result unwrap-or returns default on error" [] {
    let val = (err "fail" | result unwrap-or 0)
    assert ($val == 0)
}

@test
def "run-cmd success" [] {
    let result = (run-cmd {echo "test"})
    assert ($result | is-ok)
    assert ($result.value.stdout | str contains "test")
}

@test
def "run-cmd failure" [] {
    let result = (run-cmd {false})
    assert ($result | is-err)
    assert ($result.error.code != 0)
}

# --- Validation ADT tests ---

@test
def "valid creates success validation" [] {
    let result = (valid "value")
    assert ($result | is-valid)
    assert ($result.value == "value")
}

@test
def "invalid creates error validation" [] {
    let result = (invalid ["error1" "error2"])
    assert ($result | is-invalid)
    assert (($result.errors | length) == 2)
}

@test
def "is-valid detects success" [] {
    assert ((valid "test") | is-valid)
    assert (not ((invalid ["test"]) | is-valid))
}

@test
def "is-invalid detects error" [] {
    assert ((invalid ["test"]) | is-invalid)
    assert (not ((valid "test") | is-invalid))
}

@test
def "collect-issues accumulates all issues" [] {
    let checks = [
        {|| ["issue1"]}
        {|| ["issue2" "issue3"]}
        {|| []}
    ]
    let issues = (null | collect-issues $checks)
    assert (($issues | length) == 3)
    assert (($issues | get 0) == "issue1")
}

@test
def "collect-issues filters nulls and empty" [] {
    let checks = [
        {|| ["issue1"]}
        {|| [null]}
        {|| []}
        {|| ["issue2"]}
    ]
    let issues = (null | collect-issues $checks)
    assert (($issues | length) == 2)
}

@test
def "validation combine accumulates errors" [] {
    let validators = [
        {|x| if $x > 0 {valid $x} else {invalid ["must be positive"]}}
        {|x| if $x < 100 {valid $x} else {invalid ["must be less than 100"]}}
    ]
    let result = (-5 | validation combine $validators)
    assert ($result | is-invalid)
    assert ($result.errors | str contains "must be positive")
}

@test
def "validation combine succeeds when all valid" [] {
    let validators = [
        {|x| if $x > 0 {valid $x} else {invalid ["must be positive"]}}
        {|x| if $x < 100 {valid $x} else {invalid ["must be less than 100"]}}
    ]
    let result = (50 | validation combine $validators)
    assert ($result | is-valid)
    assert ($result.value == 50)
}

# --- Combinator tests ---

@test
def "result flat-map chains computations" [] {
    let divide = {|x| if $x != 0 {ok (10 / $x)} else {err "division by zero"}}

    let result1 = (ok 2 | result flat-map $divide)
    assert ($result1 | is-ok)
    assert ($result1.value == 5)

    let result2 = (ok 0 | result flat-map $divide)
    assert ($result2 | is-err)
}

@test
def "result flat-map short-circuits on error" [] {
    let should_not_run = {|_| ok "should not see this"}
    let result = (err "initial error" | result flat-map $should_not_run)
    assert ($result | is-err)
    assert ($result.error == "initial error")
}

@test
def "result bimap transforms both paths" [] {
    let double = {|x| $x * 2}
    let uppercase = {|s| $s | str uppercase}

    let result1 = (ok 5 | result bimap $double $uppercase)
    assert ($result1 | is-ok)
    assert ($result1.value == 10)

    let result2 = (err "error" | result bimap $double $uppercase)
    assert ($result2 | is-err)
    assert ($result2.error == "ERROR")
}

@test
def "result sequence all succeed" [] {
    let results = [(ok 1) (ok 2) (ok 3)]
    let sequenced = ($results | result sequence)
    assert ($sequenced | is-ok)
    assert ($sequenced.value == [1 2 3])
}

@test
def "result sequence fails if any fail" [] {
    let results = [(ok 1) (err "failed") (ok 3)]
    let sequenced = ($results | result sequence)
    assert ($sequenced | is-err)
}

@test
def "result try catches errors" [] {
    let safe_divide = {|x| 10 / $x}

    let result1 = (2 | result try $safe_divide)
    assert ($result1 | is-ok)

    let result2 = (0 | result try $safe_divide)
    assert ($result2 | is-err)
}

@test
def "validation map transforms valid value" [] {
    let result = (valid 5 | validation map {|x| $x * 2})
    assert ($result | is-valid)
    assert ($result.value == 10)
}

@test
def "validation map preserves invalid" [] {
    let result = (invalid ["error"] | validation map {|x| $x * 2})
    assert ($result | is-invalid)
    assert ($result.errors == ["error"])
}

@test
def "validation recover provides fallback" [] {
    assert ((valid 42 | validation recover 0) == 42)
    assert ((invalid ["error"] | validation recover 0) == 0)
}

@test
def "either type left and right" [] {
    let l = (left "error")
    assert ($l | is-left)
    assert (not ($l | is-right))

    let r = (right 42)
    assert ($r | is-right)
    assert (not ($r | is-left))
}

# --- Property-based tests (native random, self-contained) ---

@test
def "property result map preserves ok-ness" [] {
    1..50 | each {|_|
        let x = (random int 0..1000)
        let result = (ok $x | result map {|v| $v + 1})
        assert ($result | is-ok)
        assert ($result.value == ($x + 1))
    } | ignore
}

@test
def "property result unwrap-or always returns non-negative" [] {
    1..50 | each {|_|
        let x = (random int 0..1000)
        let result = if ($x mod 2 == 0) {ok $x} else {err "odd"}
        let value = ($result | result unwrap-or 0)
        assert ($value >= 0)
    } | ignore
}

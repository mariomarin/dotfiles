# Tests for nu-check.nu
use std/assert

const SCRIPT = ".scripts/nu-check.nu"

def "test script parses" [] {
    do { nu -n -c $"source ($SCRIPT)" } | complete | get exit_code | assert equal $in 0
}

def "test is-nu-shebang positive" [] {
    let result = do {
        nu -n -c 'source .scripts/nu-check.nu; is-nu-shebang "#!/usr/bin/env nu" | to nuon'
    } | complete
    assert equal ($result.stdout | str trim | from nuon) true
}

def "test is-nu-shebang with flags" [] {
    let result = do {
        nu -n -c 'source .scripts/nu-check.nu; is-nu-shebang "#!/usr/bin/env -S nu --stdin" | to nuon'
    } | complete
    assert equal ($result.stdout | str trim | from nuon) true
}

def "test is-nu-shebang negative bash" [] {
    let result = do {
        nu -n -c 'source .scripts/nu-check.nu; is-nu-shebang "#!/usr/bin/env bash" | to nuon'
    } | complete
    assert equal ($result.stdout | str trim | from nuon) false
}

def "test is-nu-shebang negative empty" [] {
    let result = do {
        nu -n -c 'source .scripts/nu-check.nu; is-nu-shebang "" | to nuon'
    } | complete
    assert equal ($result.stdout | str trim | from nuon) false
}

def "test should-check nu extension" [] {
    let result = do {
        nu -n -c 'source .scripts/nu-check.nu; should-check "foo.nu" "" | to nuon'
    } | complete
    assert equal ($result.stdout | str trim | from nuon) true
}

def "test should-check shebang fallback" [] {
    let result = do {
        nu -n -c 'source .scripts/nu-check.nu; should-check "my-script" "#!/usr/bin/env nu" | to nuon'
    } | complete
    assert equal ($result.stdout | str trim | from nuon) true
}

def "test should-check neither" [] {
    let result = do {
        nu -n -c 'source .scripts/nu-check.nu; should-check "my-script" "#!/bin/bash" | to nuon'
    } | complete
    assert equal ($result.stdout | str trim | from nuon) false
}

#!/usr/bin/env nu
# Tests for jj-pre-push.nu
use std/assert

const SCRIPT = "~/.local/bin/jj-pre-push.nu"

def "test script parses" [] {
    let exit_code = (nu -n -c $"source ($SCRIPT)" | complete | get exit_code)
    assert equal $exit_code 0
}

def "test help output" [] {
    let help = (nu $SCRIPT help | str downcase)

    assert str contains $help "check"
    assert str contains $help "push"
    assert str contains $help "pre-commit"
}

def "test parse remote line" [] {
    let line = "Changes to push to origin:"
    let result = (nu -c $"source ($SCRIPT); parse-remote '($line)'")

    assert equal $result "origin"
}

def main [] {
    print "Running jj-pre-push.nu tests..."
    print ""

    test script parses
    print "✓ Script parses without errors"

    test help output
    print "✓ Help output contains expected commands"

    test parse remote line
    print "✓ Parse remote line works"

    print ""
    print "✅ All tests passed!"
}

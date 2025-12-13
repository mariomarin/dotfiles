# Tests for health.nu
use std/assert

const SCRIPT = ".scripts/health.nu"

def "test script parses" [] {
    do { nu -n -c $"source ($SCRIPT)" } | complete | get exit_code | assert equal $in 0
}

def "test has subcommands" [] {
    let cmds = do { nu -n -c $"source ($SCRIPT); scope commands | where name =~ 'main' | get name" }
        | complete | get stdout | lines

    ["summary" "all"] | each { |sub|
        assert ($cmds | any { |c| $c =~ $sub }) $"missing ($sub) subcommand"
    } | ignore
}

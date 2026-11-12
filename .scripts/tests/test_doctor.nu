# Tests for doctor.nu
use std/assert
use helpers.nu [with-fake-bins]

const SCRIPT = ".scripts/doctor.nu"

def "test script parses" [] {
    do { ^$nu.current-exe -n -c $"source ($SCRIPT)" } | complete | get exit_code | assert equal $in 0
}

def "test has subcommands" [] {
    let cmds = do { ^$nu.current-exe -n -c $"source ($SCRIPT); scope commands | where name =~ 'main' | get name" }
    | complete
    | get stdout
    | lines

    ["summary" "all"] | each { |sub|
        assert ($cmds | any {|c| $c =~ $sub }) $"missing ($sub) subcommand"
    } | ignore
}

def "test summary passes when tools exist" [] {
    let fakes = {
        chezmoi: "exit 0"
        nvim: "exit 0"
        tmux: "exit 0"
        zsh: "exit 0"
    }
    let result = with-fake-bins $fakes {||
        do { ^$nu.current-exe --no-config-file -c "source .scripts/doctor.nu; main summary" }
        | complete
    }
    assert equal $result.exit_code 0 $result.stdout
}

def "test check-cmd reports only missing externals" [] {
    let result = do { ^$nu.current-exe -n -c "source .scripts/doctor.nu; [nu doctor-no-such-cmd] | each {|c| check-cmd $c } | compact | to nuon" } | complete
    assert equal $result.exit_code 0 $result.stderr
    assert equal ($result.stdout | str trim | from nuon) [
        {name: "doctor-no-such-cmd", fix: "install it or check PATH"}
    ]
}

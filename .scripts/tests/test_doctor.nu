# Tests for doctor.nu
use std/assert
use helpers.nu [with-fake-bins]

const SCRIPT = ".scripts/doctor.nu"

def "test script parses" []: nothing -> nothing {
    do { ^$nu.current-exe -n -c $"source ($SCRIPT)" } | complete | get exit_code | assert equal $in 0
}

def "test has subcommands" [] {
    let cmds = do { ^$nu.current-exe -n -c $"source ($SCRIPT); scope commands | where name =~ 'main' | get name" }
    | complete
    | get stdout
    | lines

    [
        "summary"
        "all"
        "chezmoi"
        "nvim"
        "tmux"
        "zim"
    ] | each { |sub|
        assert ($cmds | any {|c| $c =~ $sub }) $"missing ($sub) subcommand"
    } | ignore
}

def "test platform-components picks one OS doctor" []: nothing -> nothing {
    let result = do { ^$nu.current-exe -n -c "source .scripts/doctor.nu; platform-components | to nuon" } | complete
    assert equal $result.exit_code 0 $result.stderr
    let expected = match $nu.os-info.name {
        linux => ["nixos"]
        macos => ["darwin"]
        windows => ["wsl"]
    }
    assert equal ($result.stdout | str trim | from nuon) $expected
}

def "test summary passes when tools exist" []: nothing -> nothing {
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

def "test check-cmd reports only missing externals" []: nothing -> nothing {
    let result = do { ^$nu.current-exe -n -c "source .scripts/doctor.nu; [nu doctor-no-such-cmd] | each {|c| check-cmd $c } | compact | to nuon" } | complete
    assert equal $result.exit_code 0 $result.stderr
    assert equal ($result.stdout | str trim | from nuon) [
        {name: "doctor-no-such-cmd", fix: "install it or check PATH"}
    ]
}

def zim-issues-in [dir: path]: nothing -> list<string> {
    let result = do { ^$nu.current-exe -n -c $"source ($SCRIPT); zim-issues ($dir | to nuon) | to nuon" } | complete
    assert equal $result.exit_code 0 $result.stderr
    $result.stdout | str trim | from nuon
}

def "test zim-issues is empty for a populated ZIM_HOME" []: nothing -> nothing {
    let dir = mktemp -d
    mkdir ($dir | path join modules atuin)
    touch ($dir | path join zimfw.zsh) ($dir | path join zimrc)
    let issues = zim-issues-in $dir
    rm -rf $dir
    assert equal $issues []
}

def "test zim-issues reports missing zimfw and zimrc" []: nothing -> nothing {
    let dir = mktemp -d
    let issues = zim-issues-in $dir
    rm -rf $dir
    assert equal ($issues | length) 2
    assert ($issues | all {|i| $i =~ "chezmoi apply" })
}

def "test zim-issues reports missing modules" []: nothing -> nothing {
    let dir = mktemp -d
    touch ($dir | path join zimfw.zsh) ($dir | path join zimrc)
    let issues = zim-issues-in $dir
    rm -rf $dir
    assert equal ($issues | length) 1
    assert ($issues.0? =~ "no modules")
}

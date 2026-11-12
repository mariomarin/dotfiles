# Tests for wsl/wsl.nu (pure helpers; wsl.exe itself needs Windows)
use std/assert

const SCRIPT = "wsl/wsl.nu"

def wsl-eval [snippet: string]: nothing -> any {
    let result = do { ^$nu.current-exe -n -c $"source ($SCRIPT); ($snippet) | to nuon" } | complete
    assert equal $result.exit_code 0 $result.stderr
    $result.stdout | str trim | from nuon
}

def "test parse-distros reads utf-8 output" []: nothing -> nothing {
    assert equal (wsl-eval '"NixOS\r\nUbuntu\r\n\r\n" | parse-distros $in') [NixOS Ubuntu]
}

def "test parse-distros reads utf-16le output" []: nothing -> nothing {

    # What wsl.exe prints without WSL_UTF8, as nu sees it: NUL after each char
    # (nu can decode utf-16le but not encode it, so build the bytes by hand)
    let snippet = '"NixOS\r\nUbuntu\r\n" | split chars | each {|c| $c + (char nul) } | str join | parse-distros $in'
    assert equal (wsl-eval $snippet) [NixOS Ubuntu]
}

def "test wsl-run passes flags and strips NULs" []: nothing -> nothing {

    # Fake wsl.exe: echo args back as UTF-16-style text, record WSL_UTF8
    let bin = (mktemp --directory)
    "#!/bin/sh\nprintf '%s' \"$WSL_UTF8 $*\" | sed 's/./&\\x00/g'\n" | save $"($bin)/wsl"
    chmod +x $"($bin)/wsl"
    let r = with-env {PATH: ($env.PATH | prepend $bin)} { wsl-eval "wsl-run --list --quiet" }
    rm --recursive --force $bin
    assert equal $r {ok: true, value: "1 --list --quiet"}
}

# Evaluate snippet with a fake wsl.exe running the given sh body
def with-fake-wsl [body: string, snippet: string]: nothing -> any {
    let bin = (mktemp --directory)
    $"#!/bin/sh\n($body)\n" | save $"($bin)/wsl"
    chmod +x $"($bin)/wsl"
    let r = with-env {PATH: ($env.PATH | prepend $bin)} { wsl-eval $snippet }
    rm --recursive --force $bin
    $r
}

def "test is-provisioned matches flake hostname" []: nothing -> nothing {
    assert equal (with-fake-wsl "echo symbiont" "is-provisioned") true
}

def "test is-provisioned false on fresh image" []: nothing -> nothing {
    assert equal (with-fake-wsl "echo nixos" "is-provisioned") false
}

def "test is-provisioned false when wsl fails" []: nothing -> nothing {
    assert equal (with-fake-wsl "exit 1" "is-provisioned") false
}

def "test has-dotfiles follows exit code" []: nothing -> nothing {
    assert equal (with-fake-wsl "exit 0" "has-dotfiles") true
    assert equal (with-fake-wsl "exit 1" "has-dotfiles") false
}

def "test has-dotfiles queries chezmoi source of NIX_USER" []: nothing -> nothing {
    let log = (mktemp)
    with-fake-wsl $"echo \"$*\" > ($log)" "has-dotfiles" | ignore
    let args = open $log | str trim
    rm --force $log
    assert equal $args "-d NixOS -u mario --exec test -d /home/mario/.local/share/chezmoi"
}

def "test wsl-run-attached returns Result" []: nothing -> nothing {
    assert equal (with-fake-wsl "exit 0" "wsl-run-attached --exec ok-cmd | get ok") true
    assert equal (with-fake-wsl "exit 3" "wsl-run-attached --exec bad-cmd | get ok") false
}

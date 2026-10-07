# Tests for wsl/wsl.nu (pure helpers; wsl.exe itself needs Windows)
use std/assert

const SCRIPT = "wsl/wsl.nu"

def wsl-eval [snippet: string]: nothing -> any {
    let result = do { nu -n -c $"source ($SCRIPT); ($snippet) | to nuon" } | complete
    assert equal $result.exit_code 0 $result.stderr
    $result.stdout | str trim | from nuon
}

def "test parse-distros reads utf-8 output" [] {
    assert equal (wsl-eval '"NixOS\r\nUbuntu\r\n\r\n" | parse-distros $in') [NixOS Ubuntu]
}

def "test parse-distros reads utf-16le output" [] {
    # What wsl.exe prints without WSL_UTF8, as nu sees it: NUL after each char
    # (nu can decode utf-16le but not encode it, so build the bytes by hand)
    let snippet = '"NixOS\r\nUbuntu\r\n" | split chars | each {|c| $c + (char nul) } | str join | parse-distros $in'
    assert equal (wsl-eval $snippet) [NixOS Ubuntu]
}

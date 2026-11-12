# Tests for wsl/wsl.nu (pure helpers; wsl.exe itself needs Windows)
use std/assert
use helpers.nu [with-fake-bins]

const SCRIPT = "wsl/wsl.nu"

def wsl-eval [snippet: string]: nothing -> any {
    let result = do { ^$nu.current-exe -n -c $"source ($SCRIPT); ($snippet) | to nuon" } | complete
    assert equal $result.exit_code 0 $result.stderr
    $result.stdout | str trim | from nuon
}

def "test parse-distros reads utf-8 output" []: nothing -> nothing {
    assert equal (wsl-eval '"NixOS\r\nUbuntu\r\n\r\n" | parse-distros') [NixOS Ubuntu]
}

# What wsl.exe prints without WSL_UTF8, as nu sees it: NUL after each char
# (nu can decode utf-16le but not encode it, so build the bytes by hand)
def "test parse-distros reads utf-16le output" []: nothing -> nothing {
    let snippet = '"NixOS\r\nUbuntu\r\n" | split chars | each {|c| $c + (char nul) } | str join | parse-distros'
    assert equal (wsl-eval $snippet) [NixOS Ubuntu]
}

# Fake wsl.exe: echo args back as UTF-16-style text, record WSL_UTF8
def "test wsl-run passes flags and strips NULs" []: nothing -> nothing {
    let fake = "printf '%s' \"$WSL_UTF8 $*\" | sed 's/./&\\x00/g'"
    let r = with-fake-bins {wsl: $fake} {|| wsl-eval "wsl-run --list --quiet" }
    assert equal $r {ok: true, value: "1 --list --quiet"}
}

# Evaluate snippet with a fake wsl.exe running the given sh body
def with-fake-wsl [body: string, snippet: string]: nothing -> any {
    with-fake-bins {wsl: $body} {|| wsl-eval $snippet }
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
    let fake = 'echo "$*" > "$(dirname "$0")/args"'
    let r = with-fake-bins {wsl: $fake} {|dir|
        let found = wsl-eval "has-dotfiles"
        {found: $found, args: (open ($dir | path join args) | str trim)}
    }
    assert equal $r.found true
    assert equal $r.args "-d NixOS -u mario --exec test -d /home/mario/.local/share/chezmoi"
}

def "test wsl-run-attached returns Result" []: nothing -> nothing {
    assert equal (with-fake-wsl "exit 0" "wsl-run-attached --exec ok-cmd | get ok") true
    assert equal (with-fake-wsl "exit 3" "wsl-run-attached --exec bad-cmd | get ok") false
}

# Fake wsl.exe with an imported NixOS; $running/$host/$dotfiles shape its state
def fake-nixos [--stopped, --host: string = "symbiont", --no-dotfiles]: nothing -> string {
    let running = if $stopped { "" } else { "NixOS" }
    let dotfiles = if $no_dotfiles { 1 } else { 0 }
    [
        'case "$*" in'
        $'  "--list --quiet --running") echo "($running)" ;;'
        '  "--list --quiet") echo NixOS ;;'
        $'  *hostname) echo ($host) ;;'
        $'  *"test -d"*) exit ($dotfiles) ;;'
        'esac'
    ] | str join "\n"
}

def "test find-issues reports only missing wsl" []: nothing -> nothing {
    assert equal (with-fake-wsl "exit 1" "find-issues") ["WSL2 not installed — run: wsl --install"]
}

def "test find-issues skips distro checks while stopped" []: nothing -> nothing {
    assert equal (with-fake-wsl (fake-nixos --stopped) "find-issues") ["NixOS not running — run: just wsl-start"]
}

def "test find-issues reports provisioning and dotfiles" []: nothing -> nothing {
    let issues = with-fake-wsl (fake-nixos --host nixos --no-dotfiles) "find-issues"
    assert equal $issues [
        "NixOS not provisioned — run: just wsl/provision-nixos"
        "Dotfiles not applied — run: just wsl/apply-dotfiles"
    ]
}

def "test find-issues empty when fully set up" []: nothing -> nothing {
    assert equal (with-fake-wsl (fake-nixos) "find-issues") []
}

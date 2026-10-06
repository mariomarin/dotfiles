# Tests for clip (clipboard helper)
use std/assert

const SAMPLE = "café ☕ 中文 🎉"
# "été" in Latin-1: not valid UTF-8, so nu delivers it as binary
const LATIN1 = 0x[e9 74 e9]

# clip imports adt.nu relative to itself; stage both like chezmoi deploys them
def with-clip [body: closure] {
    let dir = (mktemp -d)
    cp private_dot_local/bin/executable_clip $"($dir)/clip"
    cp .scripts/adt.nu $"($dir)/adt.nu"
    let result = (do $body $"($dir)/clip")
    rm -rf $dir
    $result
}

# Evaluate a snippet with clip sourced; returns the nuon-decoded result
def clip-eval [snippet: string]: nothing -> any {
    let result = with-clip {|clip| do { nu -n -c $"source ($clip); ($snippet) | to nuon" } | complete }
    assert equal $result.exit_code 0 $result.stderr
    $result.stdout | str trim | from nuon
}

# Run the clip script itself with stdin and args; returns `complete` output
def run-clip [stdin: any, ...args: string]: nothing -> record {
    with-clip {|clip| do { $stdin | ^nu --stdin $clip ...$args } | complete }
}

def "test script parses" [] {
    let result = with-clip {|clip| do { nu -n -c $"source ($clip)" } | complete }
    assert equal $result.exit_code 0 $result.stderr
}

def "test select-backend priority" [] {
    let off = {ssh: false, macos: false, wsl: false, has_xclip: false, has_wl_copy: false}
    [
        [flags expected];
        [{ssh: true, macos: true} "ssh"]
        [{macos: true} "pbcopy"]
        [{wsl: true, has_xclip: true} "clip.exe"]
        [{has_xclip: true, has_wl_copy: true} "xclip"]
        [{has_wl_copy: true} "wl-copy"]
        [{} "none"]
    ]
    | each {|case|
        let flags = ($off | merge $case.flags | to nuon)
        assert equal (clip-eval $"select-backend ($flags)") $case.expected
    }
    | ignore
}

def "test backend-argv pins pbcopy locale" [] {
    let r = clip-eval "backend-argv pbcopy"
    assert equal $r.ok true
    assert equal $r.value [env LC_CTYPE=UTF-8 pbcopy]
}

def "test backend-argv none is an error" [] {
    let r = clip-eval "backend-argv none"
    assert equal $r.ok false
    assert ($r.error | str contains "no clipboard backend")
}

def "test to-bytes encodes strings as utf-8" [] {
    assert equal (clip-eval $"'($SAMPLE)' | to-bytes") ($SAMPLE | into binary)
}

def "test to-bytes passes non-utf-8 binary through" [] {
    assert equal (clip-eval $"($LATIN1 | to nuon) | to-bytes") $LATIN1
}

def "test to-bytes handles nothing" [] {
    assert equal (clip-eval "null | to-bytes") 0x[]
}

def "test read-args joins args as text" [] {
    let r = clip-eval "read-args [café 中文]"
    assert equal $r.value ("café 中文" | into binary)
}

def "test read-args reads first arg as a raw file" [] {
    let tmp = (mktemp -t "clip-latin1-XXXXXX")
    $LATIN1 | save --force --raw $tmp
    let r = clip-eval $"read-args ['($tmp)' ignored]"
    rm --force $tmp
    assert equal $r.value $LATIN1
}

def "test require-bytes rejects empty input" [] {
    let r = clip-eval "0x[] | require-bytes"
    assert equal $r.ok false
    assert ($r.error | str contains "no input")
}

def "test copy-bytes delivers exact bytes" [] {
    let tmp = (mktemp -t "clip-out-XXXXXX")
    let r = clip-eval $"copy-bytes ($SAMPLE | into binary | to nuon) [sh -c 'cat > ($tmp)']"
    let written = (open --raw $tmp | into binary)
    rm --force $tmp
    assert equal $r.ok true
    assert equal $written ($SAMPLE | into binary)
}

def "test copy-bytes reports nc failures with a hint" [] {
    let r = clip-eval "copy-bytes 0x[61] [nc -N localhost 1]"
    assert equal $r.ok false
    assert ($r.error | str contains "clipper may not be running")
}

def "test copy-bytes reports failing backends" [] {
    let r = clip-eval "copy-bytes 0x[61] [sh -c 'echo boom >&2; exit 3']"
    assert equal $r.ok false
    assert ($r.error | str contains "code 3")
    assert ($r.error | str contains "boom")
}

def "test script fails cleanly on empty stdin" [] {
    let result = run-clip ""
    assert not equal $result.exit_code 0
    assert ($result.stderr | str contains "clip: no input")
}

def "test copy-bytes reports missing commands" [] {
    let r = clip-eval "copy-bytes 0x[61] [clip-no-such-cmd]"
    assert equal $r.ok false
    assert ($r.error | str contains "not found in PATH")
}

def "test script ignores open stdin when given args" [] {
    # PATH without clipboard tools: clip fails fast instead of copying, and
    # must not wait for `sleep` to close stdin first
    let bin = (mktemp -d)
    [nu uname] | each {|cmd| ^ln -s (which $cmd | first | get path) $"($bin)/($cmd)" } | ignore
    let started = (date now)
    let result = with-clip {|clip|
        do { ^sleep 5 | with-env {PATH: [$bin], SSH_TTY: null, SSH_CONNECTION: null, SSH_CLIENT: null} { ^nu --stdin $clip hi } } | complete
    }
    rm -rf $bin
    assert ((date now) - $started < 4sec) "clip blocked on stdin despite args"
    assert ($result.stderr | str contains "clip:") $result.stderr
}

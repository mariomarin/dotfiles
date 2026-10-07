# Tests for tmux-reload.nu against a fake tmux (never the real server)
use std/assert

const SCRIPT = ".scripts/tmux-reload.nu"

# Fake tmux: list-sessions exits $SERVER, source-file exits $SOURCE; logs args
def run-reload [server: int, source: int]: nothing -> record {
    let home = (mktemp -d | path expand)
    let bin = $"($home)/bin"
    mkdir $bin
    $"#!/bin/sh\necho \"$@\" >> ($home)/tmux.log\ncase \"$1\" in\n  list-sessions\) exit ($server);;\n  source-file\) echo 'bad config' >&2; exit ($source);;\nesac\n" | save $"($bin)/tmux"
    ^chmod +x $"($bin)/tmux"
    let result = with-env {HOME: $home, PATH: ($env.PATH | prepend $bin)} { do { ^$nu.current-exe -n $SCRIPT } | complete }
    let log = if ($"($home)/tmux.log" | path exists) { open --raw $"($home)/tmux.log" | lines } else { [] }
    rm -rf $home
    $result | insert calls $log | insert home $home
}

def "test no server means nothing to reload" [] {
    let r = run-reload 1 0
    assert equal $r.exit_code 0 $r.stderr
    assert equal $r.calls ["list-sessions"]
}

def "test running server re-sources tmux.conf" [] {
    let r = run-reload 0 0
    assert equal $r.exit_code 0 $r.stderr
    assert equal $r.calls ["list-sessions" $"source-file ($r.home)/.config/tmux/tmux.conf"]
}

def "test source failure exits 1 with the tmux error" [] {
    let r = run-reload 0 1
    assert equal $r.exit_code 1
    assert ($r.stderr | str contains "tmux reload failed: bad config") $r.stderr
}

# Tests for atuin-doctor parsers and classifiers (fixtures, no atuin needed)
use std/assert

const SCRIPT = ".scripts/atuin-doctor.nu"
const NOW = 2026-10-06T12:00:00Z

def doctor-eval [snippet: string]: nothing -> any {
    let result = do { nu -n -c $"source ($SCRIPT); ($snippet) | to nuon" } | complete
    assert equal $result.exit_code 0 $result.stderr
    $result.stdout | str trim | from nuon
}

def "test script parses" [] {
    let result = do { nu -n -c $"source ($SCRIPT)" } | complete
    assert equal $result.exit_code 0 $result.stderr
}

def "test parse-tracing-lines keeps levels and targets" [] {
    let lines = [
        "2026-10-06T10:00:00.123456Z ERROR atuin_client::sync: failed to sync: 413 Payload Too Large"
        "2026-10-06T10:00:01Z  INFO atuin: search started"
        "\e[31m2026-10-06T10:00:02Z\e[0m  WARN no target here"
        "not a log line"
    ]
    let parsed = doctor-eval $"($lines | to nuon) | parse-tracing-lines"
    assert equal ($parsed | get level) [ERROR INFO WARN]
    assert equal $parsed.0.target "atuin_client::sync"
    assert equal $parsed.0.msg "failed to sync: 413 Payload Too Large"
    assert equal $parsed.2.msg "no target here"
    assert equal $parsed.0.ts 2026-10-06T10:00:00.123456Z
}

def "test parse-journal-json decodes string and byte messages" [] {
    # journald emits non-UTF-8 MESSAGE as an array of bytes ("caf\xe9 ERROR")
    let journal = [
        ({MESSAGE: "listening on 127.0.0.1:8888", PRIORITY: "6", SYSLOG_IDENTIFIER: "atuin-server", __REALTIME_TIMESTAMP: "1791280800000000"} | to json -r)
        ({MESSAGE: "atuin-server.service: Failed with result 'exit-code'.", PRIORITY: "4", SYSLOG_IDENTIFIER: "systemd", __REALTIME_TIMESTAMP: "1791280801000000"} | to json -r)
        ({MESSAGE: [99 97 102 233 32 69 82 82 79 82], PRIORITY: "6", __REALTIME_TIMESTAMP: "1791280802000000"} | to json -r)
    ] | str join "\n"
    let entries = doctor-eval $"($journal | to nuon) | parse-journal-json"
    assert equal ($entries | length) 3
    assert equal $entries.0.msg "listening on 127.0.0.1:8888"
    assert equal $entries.1.source "systemd"
    assert equal $entries.2.msg "caf� ERROR"
    assert equal $entries.0.ts (1791280800 * 1_000_000_000 | into datetime)
}

def "test journal-problems filters noise" [] {
    let entries = [
        [priority msg];
        [6 "listening on 127.0.0.1:8888"]
        [3 "something at err priority"]
        [6 "2026-10-06T10:00:00Z ERROR atuin_server: boom"]
        [4 "atuin-server.service: Failed with result 'exit-code'."]
        [6 "Error: Address already in use (os error 98)"]
    ]
    let kept = doctor-eval $"($entries | to nuon) | journal-problems | get msg"
    assert equal ($kept | length) 4
    assert ("listening on 127.0.0.1:8888" not-in $kept)
}

def "test classify-server-error recognises known failures" [] {
    [
        [msg expected];
        ["Error: Address already in use (os error 98)" "port already in use"]
        ["error returned from database: unable to open database file" "cannot write its database"]
        ["database is locked" "database is locked"]
        ["413 Payload Too Large" "oversized record"]
        ["atuin-server.service: Start request repeated too quickly." "crash-looped"]
        ["thread 'main' panicked at src/main.rs" "panicked"]
    ]
    | each {|case|
        let r = doctor-eval $"classify-server-error ($case.msg | to nuon)"
        assert ($r.message | str contains $case.expected) $r.message
    }
    | ignore
    assert equal (doctor-eval "classify-server-error 'all good'") null
}

def "test parse-atuin-doctor skips banner" [] {
    let out = "Atuin Doctor\nChecking for diagnostics\n\n{\n  \"atuin\": {\"version\": \"18.21.0\"}\n}"
    let r = doctor-eval $"($out | to nuon) | parse-atuin-doctor"
    assert equal $r.ok true
    assert equal $r.value.atuin.version "18.21.0"
    assert equal (doctor-eval "'no json here' | parse-atuin-doctor").ok false
}

def "test parse-last-sync reads utc timestamps" [] {
    assert equal (doctor-eval "parse-last-sync '2026-10-02 22:37:04.477336 +00:00:00'") 2026-10-02T22:37:04Z
    assert equal (doctor-eval "parse-last-sync '2026-10-07 2:27:07.771436 +00:00:00'") 2026-10-07T02:27:07Z
    assert equal (doctor-eval "parse-last-sync ''") null
}

def "test sync-issues" [] {
    let authed = "Self-hosted (authenticated)"
    [
        [sync expected];
        [{auth_state: "Not logged in", auto_sync: true, last_sync: ""} "not logged in"]
        [{auth_state: $authed, auto_sync: true, last_sync: "2026-10-02 22:37:04.477336 +00:00:00"} "last sync 3d ago"]
        [{auth_state: $authed, auto_sync: true, last_sync: ""} "never synced"]
        [{auth_state: $authed, auto_sync: true, last_sync: "2026-10-06 11:00:00.0 +00:00:00"} null]
        [{auth_state: $authed, auto_sync: false, last_sync: "2020-01-01 00:00:00.0 +00:00:00"} null]
    ]
    | each {|case|
        let issues = doctor-eval $"sync-issues ($case.sync | to nuon) ($NOW | to nuon)"
        if $case.expected == null {
            assert equal $issues []
        } else {
            assert ($issues.0.message | str contains $case.expected) $issues.0.message
        }
    }
    | ignore
}

def "test version-issues" [] {
    assert equal (doctor-eval "version-issues 18.21.0 18.16.1").0.severity "warning"
    assert equal (doctor-eval "version-issues 19.0.0 18.16.1").0.severity "error"
    assert equal (doctor-eval "version-issues 18.16.1 18.21.0") []
    assert equal (doctor-eval "version-issues 18.21.0 18.21.0") []
}

def "test resolve-sync-address precedence" [] {
    assert equal (doctor-eval "resolve-sync-address http://env:8888/ http://cfg:8888") {addr: "http://env:8888", source: "$ATUIN_SYNC_ADDRESS"}
    assert equal (doctor-eval "resolve-sync-address '' http://cfg:8888").source "sync_address in config.toml"
    assert equal (doctor-eval "resolve-sync-address").addr "https://api.atuin.sh"
}

def "test summarize-problems dedupes and counts" [] {
    let problems = [
        [ts msg];
        [2026-10-06T10:00:00Z "sync failed"]
        [2026-10-06T11:00:00Z "sync failed"]
        [2026-10-06T10:30:00Z "Error: Address already in use"]
    ]
    let issues = doctor-eval $"($problems | to nuon) | summarize-problems 'server log'"
    assert equal ($issues | length) 2
    # newest last; known errors classified, others reported with a count
    assert equal $issues.0.message "port already in use"
    assert equal $issues.1.message "sync failed (x2)"
}

# Run snippet with fake systemctl/journalctl first on PATH
def with-fake-systemd [show: string, journal: string, snippet: string]: nothing -> any {
    let bin = (mktemp -d)
    $show | save $"($bin)/show.txt"
    $"#!/bin/sh\ncase \"$2\" in cat\) exit 0;; show\) cat ($bin)/show.txt;; esac\n" | save $"($bin)/systemctl"
    $journal | save $"($bin)/journal.json"
    $"#!/bin/sh\necho \"$@\" > ($bin)/journalctl.args\ncat ($bin)/journal.json\n" | save $"($bin)/journalctl"
    ^chmod +x $"($bin)/systemctl" $"($bin)/journalctl"
    let result = with-env {PATH: ($env.PATH | prepend $bin)} { doctor-eval $"{issues: \(($snippet)\), args: \(open ($bin)/journalctl.args | str trim\)}" }
    rm -rf $bin
    $result
}

def "test server checks read fake systemd" [] {
    let journal = [
        ({MESSAGE: "Error: Address already in use (os error 98)", PRIORITY: "6", __REALTIME_TIMESTAMP: "1791280800000000"} | to json -r)
        ({MESSAGE: "atuin-server.service: Failed with result 'exit-code'.", PRIORITY: "4", __REALTIME_TIMESTAMP: "1791280801000000"} | to json -r)
    ] | str join "\n"
    let r = with-fake-systemd "ActiveState=failed\nSubState=failed\nNRestarts=3" $journal "(check-server-unit) ++ (check-server-journal)"
    assert equal ($r.issues | get message) [
        "atuin-server.service is failed/failed"
        "port already in use"
        "atuin-server.service: Failed with result 'exit-code'."
    ]
    assert ($r.args | str contains "--since 24 hours ago") $r.args
}

def "test server checks quiet when active" [] {
    let r = with-fake-systemd "ActiveState=active\nSubState=running\nNRestarts=0" "" "(check-server-unit) ++ (check-server-journal)"
    assert equal $r.issues []
}

def "test parse-exec-path" [] {
    let show = "ExecStart={ path=/home/u/.local/share/ribosome-env/bin/atuin-server ; argv[]=/home/u/.local/share/ribosome-env/bin/atuin-server start ; ignore_errors=no }"
    assert equal (doctor-eval $"($show | to nuon) | parse-exec-path") "/home/u/.local/share/ribosome-env/bin/atuin-server"
    assert equal (doctor-eval "'ExecStart=' | parse-exec-path") null
}

def "test parse-server-url" [] {
    assert equal (doctor-eval "'Environment=ATUIN_HOST=0.0.0.0 ATUIN_PORT=9999 ATUIN_DB_URI=x' | parse-server-url") "http://0.0.0.0:9999"
    assert equal (doctor-eval "'Environment=' | parse-server-url") "http://127.0.0.1:8888"
}

def "test stale-binary-issues" [] {
    assert equal (doctor-eval "stale-binary-issues 18.21.0 18.21.0") []
    let r = doctor-eval "stale-binary-issues 18.21.0 18.16.1"
    assert equal $r.0.message "runs 18.16.1 but 18.21.0 is installed"
    assert ($r.0.fix | str contains "restart")
}

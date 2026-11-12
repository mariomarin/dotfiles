# Tests for atuin-doctor parsers and classifiers (fixtures, no atuin needed)
use std/assert

const SCRIPT = ".scripts/atuin-doctor.nu"
const NOW = 2026-10-06T12:00:00Z

def doctor-eval [snippet: string]: nothing -> any {
    let result = do { ^$nu.current-exe -n -c $"source ($SCRIPT); ($snippet) | to nuon" } | complete
    assert equal $result.exit_code 0 $result.stderr
    $result.stdout | str trim | from nuon
}

def "test script parses" [] {
    let result = do { ^$nu.current-exe -n -c $"source ($SCRIPT)" } | complete
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
        [sync, expected];
        [{auth_state: "Not logged in", auto_sync: true, last_sync: ""}, "not logged in"]
        [{auth_state: $authed, auto_sync: true, last_sync: "2026-10-02 22:37:04.477336 +00:00:00"}, "last sync 3d ago"]
        [{auth_state: $authed, auto_sync: true, last_sync: ""}, "never synced"]
        [{auth_state: $authed, auto_sync: true, last_sync: "2026-10-06 11:00:00.0 +00:00:00"}, null]
        [{auth_state: $authed, auto_sync: false, last_sync: "2020-01-01 00:00:00.0 +00:00:00"}, null]
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
        [ts, msg];
        [2026-10-06T10:00:00Z, "sync failed"]
        [2026-10-06T11:00:00Z, "sync failed"]
        [2026-10-06T10:30:00Z, "database error"]
    ]
    let issues = doctor-eval $"($problems | to nuon) | summarize-problems 'client log'"
    assert equal ($issues | length) 2
    # newest last, repeats counted
    assert equal $issues.0.message "database error"
    assert equal $issues.1.message "sync failed (x2)"
}

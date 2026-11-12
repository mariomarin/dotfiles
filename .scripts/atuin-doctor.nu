#!/usr/bin/env nu
# Atuin doctor: client (sync state, server reachability, ~/.atuin/logs) and,
# where the NixOS atuin unit exists (symbiont), the server (state, journal).
# Silent when healthy; prints `atuin:` issues and exits 1 otherwise.

use adt.nu [ok, err, run-cmd, collect-issues, "result map", "result flat-map", "result unwrap-or", "result bimap"]

const SERVER_UNIT = "atuin.service"
# Window of log history worth reporting (atuin keeps 4 days of client logs)
const LOG_WINDOW = 1day
const STALE_SYNC = 1day

def issue [component: string, severity: string, message: string, fix?: string]: nothing -> record {
    {component: $component, severity: $severity, message: $message, fix: ($fix | default null)}
}

# --- Parsing (pure) ---

# tracing text lines: `2026-10-02T22:37:04.477Z ERROR atuin::sync: message`
def parse-tracing-lines []: list<string> -> table {
    $in
    | ansi strip
    | parse --regex '^(?<ts>\d{4}-\d\d-\d\dT\S+)\s+(?<level>TRACE|DEBUG|INFO|WARN|ERROR)\s+(?:(?<target>[\w:]+): )?(?<msg>.*)$'
    | update ts {|r| try { $r.ts | into datetime } catch { null } }
}

# `journalctl -o json` output: one object per line. MESSAGE is an array of
# bytes when it is not valid UTF-8, so decode it rather than assume a string.
def parse-journal-json []: string -> table {
    $in
    | lines
    | where {|l| $l | str starts-with "{" }
    | each {|l| $l | from json }
    | each {|e|
        let message = match ($e.MESSAGE? | describe) {
            "string" => $e.MESSAGE
            $t if ($t | str starts-with "list") => ($e.MESSAGE | each {|b| $b | into binary | bytes at 0..0 } | bytes collect | decode utf-8)
            _ => ""
        }
        {
            ts: ($e.__REALTIME_TIMESTAMP? | default "0" | into int | $in * 1000 | into datetime)
            priority: ($e.PRIORITY? | default "6" | into int)
            source: ($e.SYSLOG_IDENTIFIER? | default "")
            msg: ($message | ansi strip)
        }
    }
}

# Server journal entries that matter: syslog err or worse, tracing WARN/ERROR,
# or a fatal `Error: …` (printed to stdout, so journald files it as info)
def journal-problems []: table -> table {
    $in | where {|e| $e.priority <= 3 or $e.msg =~ '\b(ERROR|WARN)\b|^Error: |[Ff]ailed|panicked' }
}

# Known server failures → actionable issue; null when not recognised
def classify-server-error [msg: string]: nothing -> any {
    match $msg {
        $m if ($m =~ '(?i)address already in use') => (issue "server" "error" "port already in use" "ss -ltnp 'sport = :8888' to find the other listener")
        $m if ($m =~ '(?i)unable to open database|readonly database|permission denied') => (issue "server" "error" $"cannot write its database: ($m)" "check the database: sudo systemctl status postgresql")
        $m if ($m =~ '(?i)database is locked') => (issue "server" "warning" "database is locked" "stop other atuin-server instances")
        $m if ($m =~ '(?i)payload too large|record too large|413') => (issue "server" "error" "rejected an oversized record" "raise ATUIN_MAX_RECORD_SIZE via systemd.services.atuin.environment on symbiont")
        $m if ($m =~ 'Start request repeated too quickly') => (issue "server" "error" "crash-looped and systemd gave up" $"sudo systemctl reset-failed ($SERVER_UNIT) && sudo systemctl start ($SERVER_UNIT)")
        $m if ($m =~ 'panicked') => (issue "server" "error" $"panicked: ($m)")
        _ => null
    }
}

# `atuin doctor` prints a banner, then JSON
def parse-atuin-doctor []: string -> record {
    let json = ($in | lines | skip until {|l| $l | str starts-with "{" } | str join "\n")
    match (try { $json | from json } catch { null }) {
        null => (err "could not parse `atuin doctor` output")
        $report => (ok $report)
    }
}

# `last_sync` looks like `2026-10-02 22:37:04.477336 +00:00:00` (UTC); the
# hour is not zero-padded (`2026-10-07 2:27:07…`)
def parse-last-sync [raw: string]: nothing -> any {
    match ($raw | parse --regex '^(?<date>\d{4}-\d\d-\d\d) (?<hour>\d{1,2}):(?<rest>\d\d:\d\d)') {
        [{date: $d, hour: $h, rest: $r}] => ($"($d)T($h | fill -a right -c '0' -w 2):($r)Z" | into datetime)
        _ => null
    }
}

def sync-issues [sync: record, now: datetime]: nothing -> list<record> {
    if not ($sync.auth_state? | default "" | str contains "authenticated") {
        return [(issue "sync" "error" $"not logged in \(($sync.auth_state? | default 'unknown')\)" "atuin login")]
    }
    if not ($sync.auto_sync? | default false) { return [] }
    match (parse-last-sync ($sync.last_sync? | default "")) {
        null => [(issue "sync" "error" "has never synced" "atuin sync")]
        $last if ($now - $last) > $STALE_SYNC => [(issue "sync" "error" $"last sync ((($now - $last) / 1day) | math floor)d ago despite auto_sync" $"atuin sync; (server-hint)")]
        _ => []
    }
}

# "18.21.0" → [18 21 0]
def version-parts [v: string]: nothing -> list<int> {
    $v | str trim | split row "." | each {|p| $p | into int }
}

def version-issues [client: string, server: string]: nothing -> list<record> {
    match [(version-parts $client) (version-parts $server)] {
        [[$cm, $cn, ..], [$sm, $sn, ..]] if $cm != $sm => [(issue "sync" "error" $"client ($client) and server ($server) major versions differ" "upgrade the older side")]
        [[_, $cn, ..], [_, $sn, ..]] if $cn > $sn => [(issue "sync" "warning" $"client ($client) is newer than server ($server)" "update the server on symbiont (nix flake update, just nixos)")]
        _ => []
    }
}

# Sync server the way atuin picks it: env, then config.toml, then default
def resolve-sync-address [env_value?: string, config_value?: string]: nothing -> record {
    match [$env_value $config_value] {
        [$e, _] if ($e | is-not-empty) => {addr: $e, source: "$ATUIN_SYNC_ADDRESS"}
        [_, $c] if ($c | is-not-empty) => {addr: $c, source: "sync_address in config.toml"}
        _ => {addr: "https://api.atuin.sh", source: "atuin default"}
    }
    | update addr {|r| $r.addr | str trim --right --char "/" }
}

# Latest occurrence of each distinct problem, newest last
def summarize-problems [label: string]: table -> list<record> {
    $in
    | group-by msg --to-table
    | each {|g| {msg: $g.msg, count: ($g.items | length), ts: ($g.items | get ts | math max)} }
    | sort-by ts
    | last 5
    | each {|p|
        let times = if $p.count > 1 { $" \(x($p.count)\)" } else { "" }
        classify-server-error $p.msg | default (issue $label "warning" $"($p.msg)($times)")
    }
}

# --- Client ---

def client-log-dir []: nothing -> string {
    let config = ($env.HOME | path join ".config" "atuin" "config.toml")
    let dir = if ($config | path exists) { open $config | get -o logs.dir } else { null }
    $dir | default ($env.HOME | path join ".atuin" "logs") | path expand
}

def check-client-logs [now: datetime]: nothing -> list<record> {
    let dir = (client-log-dir)
    if not ($dir | path exists) { return [] }
    glob $"($dir)/*.log*"
    | each {|f| open --raw $f | decode utf-8 | lines | parse-tracing-lines | insert file ($f | path basename | str replace -r '\.log.*' '') }
    | flatten
    | where {|l| $l.level in [WARN ERROR] and $l.ts != null and ($now - $l.ts) < $LOG_WINDOW }
    | each {|l| $l | update msg $"($l.file): ($l.msg)" }
    | summarize-problems "client log"
}

def check-sync [now: datetime]: nothing -> list<record> {
    run-cmd {^atuin doctor}
    | result flat-map {|out| $out.stdout | parse-atuin-doctor }
    | result map {|report| sync-issues $report.atuin.sync $now }
    | match $in {
        {ok: true, value: $issues} => $issues
        {error: $e} => [(issue "sync" "error" $"atuin doctor failed: ($e | to text | str trim)")]
    }
}

def server-version [addr: string]: nothing -> record {
    run-cmd {^curl -fsS -m 5 $"($addr)/"}
    | result bimap {|out| $out.stdout } {|failure| $failure.stderr | str trim }
    | result flat-map {|body| match (try { $body | from json } catch { null }) {
        {version: $v} => (ok $v)
        _ => (err $"unexpected response from ($addr)")
    } }
}

def check-server-reachable []: nothing -> list<record> {
    let config = ($env.HOME | path join ".config" "atuin" "config.toml")
    let configured = if ($config | path exists) { open $config | get -o sync_address } else { null }
    let sync = (resolve-sync-address $env.ATUIN_SYNC_ADDRESS? $configured)

    let client = (run-cmd {^atuin --version} | result map {|out| $out.stdout | parse --regex '(?<v>\d+\.\d+\.\d+)' | get 0.v } | result unwrap-or "")
    match (server-version $sync.addr) {
        {ok: true, value: $server} => (version-issues $client $server)
        {error: $e} => {
            [(issue "sync" "error" $"server ($sync.addr) \(from ($sync.source)\) unreachable: ($e)" $"check ($sync.source)")]
        }
    }
}

# --- Server (only where the system unit exists) ---

def server-hint []: nothing -> string {
    if (has-server-unit) { "see server issues" } else { "run `just atuin-doctor` on the sync server for its logs" }
}

def has-server-unit []: nothing -> bool {
    (which systemctl | is-not-empty) and (run-cmd {^systemctl cat $SERVER_UNIT} | get ok)
}

def check-server-unit []: nothing -> list<record> {
    let props = (run-cmd {^systemctl show $SERVER_UNIT -p ActiveState -p SubState -p NRestarts}
        | result map {|out| $out.stdout | lines | parse "{key}={value}" | transpose -r -d }
        | result unwrap-or {})
    match $props {
        {ActiveState: "active"} if (($props.NRestarts? | default "0" | into int) > 0) => [(issue "server" "warning" $"restarted ($props.NRestarts) times since boot" $"journalctl -u ($SERVER_UNIT)")]
        {ActiveState: "active"} => []
        {ActiveState: $state} => [(issue "server" "error" $"($SERVER_UNIT) is ($state)/($props.SubState? | default '?')" $"sudo systemctl restart ($SERVER_UNIT)")]
        _ => [(issue "server" "error" "cannot read unit state" $"systemctl status ($SERVER_UNIT)")]
    }
}

def check-server-journal []: nothing -> list<record> {
    run-cmd {^journalctl -u $SERVER_UNIT --since $"($LOG_WINDOW / 1hr | math round) hours ago" -o json --no-pager}
    | result map {|out| $out.stdout | parse-journal-json | journal-problems | summarize-problems "server log" }
    | result unwrap-or [(issue "server" "warning" "cannot read journal" $"journalctl -u ($SERVER_UNIT)")]
}

# --- Report ---

def report-issues [issues: list<record>] {
    print "atuin:"
    $issues | each {|i|
        let fix = if ($i.fix | is-not-empty) { $" — ($i.fix)" } else { "" }
        print $"  ($i.component): ($i.message)($fix)"
    } | ignore
    exit 1
}

def main [] {
    if (which atuin | is-empty) { return }
    let now = (date now)
    let server_checks = if (has-server-unit) { [{|| check-server-unit} {|| check-server-journal}] } else { [] }
    let issues = (null | collect-issues ([
        {|| check-sync $now}
        {|| check-server-reachable}
        {|| check-client-logs $now}
    ] | append $server_checks))
    if ($issues | is-empty) { return }
    report-issues $issues
}

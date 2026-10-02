#!/usr/bin/env nu

use adt.nu [run-cmd, is-ok, is-err, collect-issues]

# Structured issue type
def issue [
    component: string  # Which component has the issue
    severity: string   # error | warning | info
    message: string    # Human-readable description
    fix?: string       # Optional fix command/instruction
]: nothing -> record {
  {
    component: $component
    severity: $severity
    message: $message
    fix: ($fix | default null)
  }
}

def main [] {
    match (^uname -s | str trim) {
        "Darwin" => {doctor-darwin}
        "Linux" => {doctor-linux}
        $os => {
            print $"kanata: unsupported OS ($os)"
            exit 1
        }
    }
}

# Returns {state: string} where state is one of:
#   running | stopped | not-loaded | codesigning-killed | spawn-scheduled
def launchd-state [label: string]: nothing -> record<state: string> {
    let out = (run-cmd {^launchctl print $"system/($label)"})
    if ($out | is-err) {return {state: "not-loaded"}}
    if ($out.value.stdout | str contains "state = running") {return {state: "running"}}
    if ($out.value.stdout | str contains "state = spawn scheduled") {return {state: "spawn-scheduled"}}
    if ($out.value.stdout | str contains "OS_REASON_CODESIGNING") {return {state: "codesigning-killed"}}
    {state: "stopped"}
}

def restart-cmd [label: string]: nothing -> string {
    $"sudo launchctl kickstart -k system/($label)"
}

def check-bin [bin: string]: nothing -> list<record> {
    if not ($bin | path exists) {
        return [(issue "binary" "error" "binary missing" "just darwin")]
    }
    let sig = (run-cmd {^codesign -d --verbose=2 $bin})
    if ($sig | is-ok) and ($sig.value.stderr | str contains "linker-signed") {
        [(issue "binary" "error" "bad signature (linker-signed)" $"sudo codesign --force --sign - ($bin)")]
    } else {[]}
}

def check-sock-dir []: nothing -> list<record> {
    let dir = "/Library/Application Support/org.pqrs/tmp"
    if not ($dir | path exists) {
        [(issue "vhid" "error" "socket dir missing" $"sudo mkdir -p '($dir)' && sudo chmod 1777 '($dir)'")]
    } else {[]}
}

def check-cfg [file: string]: nothing -> list<record> {
    if not ($file | path exists) {
        [(issue "config" "error" "config missing" "chezmoi apply")]
    } else {[]}
}

def check-vhid [label: string]: nothing -> list<record> {
    let s = (launchd-state $label)
    # spawn-scheduled is acceptable - service is configured and will start on demand
    if $s.state == "running" or $s.state == "spawn-scheduled" {
        []
    } else {
        let cmd = (restart-cmd $label)
        [(issue "vhid" "error" "karabiner-vhid not running" $cmd)]
    }
}

# kanata needs both permissions but only reports the first one it fails on,
# so also ask tccd which grants exist but no longer match the binary.
# Ad-hoc signed binaries are granted by cdhash: every rebuild orphans them.
const TCC_SERVICES = {
    kTCCServiceListenEvent: "Input Monitoring"
    kTCCServiceAccessibility: "Accessibility"
}

def find-denied-permissions [log: string]: nothing -> list<string> {
    if not ($log | path exists) { return [] }
    open --raw $log
    | lines
    | last 5
    | parse --regex 'macOS (?<perm>Input Monitoring|Accessibility) permission'
    | get perm
}

def find-stale-permissions [bin: string]: nothing -> list<string> {
    let pred = $"process == \"tccd\" AND eventMessage CONTAINS \"Failed to match existing code requirement for subject ($bin)\""
    ^/usr/bin/log show --last 5m --style compact --predicate $pred
    | parse --regex 'service (?<svc>kTCCService\w+)'
    | get svc
    | uniq
    | each {|svc| $TCC_SERVICES | get -o $svc }
    | compact
}

def has-no-devices [log: string]: nothing -> bool {
    if not ($log | path exists) { return false }
    open --raw $log | lines | last 5 | any {|l| $l | str contains "Couldn't register any device" }
}

def check-permissions [bin: string, label: string]: nothing -> list<record> {
    let stale = (find-stale-permissions $bin)
    let denied = (find-denied-permissions "/tmp/kanata.err.log")
    let perms = $stale | append $denied | uniq
    if ($perms | is-empty) {return []}

    let cmd = (restart-cmd $label)
    $perms
    | each {|perm|
        let why = if $perm in $stale {"stale entry from an older build"} else {"not granted"}
        let fix = $"System Settings → Privacy & Security → ($perm), remove kanata \(−\), re-add ($bin) \(+, ⌘⇧G\), then: ($cmd)"
        issue "permissions" "error" $"($perm) permission denied \(($why)\)" $fix
    }
}

def format-log-tail [log: string]: nothing -> list<string> {
    if not ($log | path exists) { return [] }
    let lines = open --raw $log | lines | last 10
    if ($lines | is-empty) { return [] }
    ["  last error:"] | append ($lines | each {|line| $"    ($line)"})
}

def check-kanata [label: string, bin: string, vhid_running: bool]: nothing -> list<record> {
    let s = (launchd-state $label)
    let cmd = (restart-cmd $label)
    match $s.state {
        "not-loaded" => [(issue "kanata" "error" "kanata service not loaded" "just darwin")]
        "codesigning-killed" => [(issue "kanata" "error" "killed by codesigning" $"sudo codesign --force --sign - ($bin), then re-grant Input Monitoring")]
        "stopped" => {
            let perm_issues = (check-permissions $bin $label)
            if ($perm_issues | is-not-empty) {return $perm_issues}
            if (has-no-devices "/tmp/kanata.err.log") {
                return [(issue "kanata" "error" "no configured keyboard connected" "compare `kanata --list` with macos-dev-names-include in ~/.config/kanata/darwin.kbd")]
            }
            let hint = if not $vhid_running {" (start karabiner-vhid first)"} else {""}
            let log_tail = (format-log-tail "/tmp/kanata.err.log")
            let msg = if ($log_tail | is-not-empty) {
                $"kanata not running($hint)\n($log_tail | str join '\n')"
            } else {
                $"kanata not running($hint)"
            }
            [(issue "kanata" "error" $msg $cmd)]
        }
        _ => []
    }
}

def doctor-darwin [] {
    let bin = "/usr/local/bin/kanata"
    let vhid_label = "org.pqrs.Karabiner-VirtualHIDDevice-Daemon"
    let config = $env.HOME | path join ".config/kanata/darwin.kbd"

    # Collect all issues using applicative validation pattern
    let issues = (collect-issues [
        {|| check-bin $bin}
        {|| check-sock-dir}
        {|| check-cfg $config}
        {|| check-vhid $vhid_label}
        {||
            let vhid_ok = ((check-vhid $vhid_label) | is-empty)
            check-kanata "org.nixos.kanata" $bin $vhid_ok
        }
    ])

    if ($issues | is-empty) {return}
    report-issues $issues
}

def check-kanata-linux []: nothing -> list<record> {
    let status = (run-cmd {^systemctl status kanata-laptop.service})
    if ($status | is-err) and ($status.error.code == 4) {
        return [(issue "kanata" "error" "kanata service not found" "just nixos")]
    }
    if ($status | is-ok) and (($status.value.stdout | str contains "inactive") or ($status.value.stdout | str contains "failed")) {
        return [(issue "kanata" "error" "kanata not running" "sudo systemctl restart kanata-laptop.service")]
    }
    []
}

def doctor-linux [] {
    let config = $env.HOME | path join ".config/kanata/core.kbd"

    let issues = (collect-issues [
        {|| check-kanata-linux}
        {|| check-cfg $config}
    ])

    if ($issues | is-empty) {return}
    report-issues $issues
}

# Format and report structured issues
def report-issues [issues: list<record>] {
    print "kanata:"
    $issues | each {|i|
        let msg = if ($i.fix | is-not-empty) {
            $"($i.message) — ($i.fix)"
        } else {
            $i.message
        }
        print $"  ($msg)"
    } | ignore
    exit 1
}

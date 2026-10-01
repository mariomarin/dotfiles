#!/usr/bin/env nu

def main [] {
    match (^uname -s | str trim) {
        "Darwin" => { doctor-darwin }
        "Linux" => { doctor-linux }
        $os => {
            print $"kanata: unsupported OS ($os)"
            exit 1
        }
    }
}

# Returns {state: string} where state is one of:
#   running | stopped | not-loaded | codesigning-killed
def launchd-state [label: string] {
    let out = do { ^launchctl print $"system/($label)" } | complete
    if $out.exit_code != 0 { return {state: "not-loaded"} }
    if ($out.stdout | str contains "state = running") { return {state: "running"} }
    if ($out.stdout | str contains "OS_REASON_CODESIGNING") { return {state: "codesigning-killed"} }
    {state: "stopped"}
}

def restart-cmd [label: string] {
    $"sudo launchctl stop ($label) && sudo launchctl start ($label)"
}

def check-bin [bin: string]: nothing -> list<string> {
    if not ($bin | path exists) { return ["binary missing — run: just darwin"] }
    let sig = do { ^codesign -d --verbose=2 $bin } | complete
    if ($sig.stderr | str contains "linker-signed") {
        [$"bad signature \(linker-signed\) — run: sudo codesign --force --sign - ($bin)"]
    } else { [] }
}

def check-sock-dir []: nothing -> list<string> {
    let dir = "/Library/Application Support/org.pqrs/tmp"
    if not ($dir | path exists) {
        [$"socket dir missing — run: sudo mkdir -p '($dir)' && sudo chmod 1777 '($dir)'"]
    } else { [] }
}

def check-cfg [file: string]: nothing -> list<string> {
    if not ($file | path exists) { ["config missing — run: chezmoi apply"] } else { [] }
}

def check-vhid [label: string]: nothing -> list<string> {
    let s = (launchd-state $label)
    if $s.state != "running" {
        let cmd = (restart-cmd $label)
        [$"karabiner-vhid not running — run: ($cmd)"]
    } else { [] }
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

def check-permissions [bin: string, label: string]: nothing -> list<string> {
    let stale = (find-stale-permissions $bin)
    let denied = (find-denied-permissions "/tmp/kanata.err.log")
    let perms = $stale | append $denied | uniq
    if ($perms | is-empty) { return [] }

    $perms
    | each {|perm|
        let why = if $perm in $stale { "stale entry from an older build" } else { "not granted" }
        $"($perm) permission denied \(($why)\) — fix: System Settings → Privacy & Security → ($perm), remove kanata \(−\), re-add ($bin) \(+, ⌘⇧G\)"
    }
    | append $"then: sudo launchctl kickstart -k system/($label)"
}

def check-kanata [label: string, bin: string, vhid_running: bool]: nothing -> list<string> {
    let s = (launchd-state $label)
    let cmd = (restart-cmd $label)
    match $s.state {
        "not-loaded" => ["kanata service not loaded — run: just darwin"]
        "codesigning-killed" => [$"killed by codesigning — fix: sudo codesign --force --sign - ($bin), then re-grant Input Monitoring"]
        "stopped" => {
            let perm_issues = (check-permissions $bin $label)
            if ($perm_issues | is-not-empty) { return $perm_issues }
            if (has-no-devices "/tmp/kanata.err.log") {
                return ["no configured keyboard connected — compare `kanata --list` with macos-dev-names-include in ~/.config/kanata/darwin.kbd"]
            }
            let hint = if not $vhid_running { " (start karabiner-vhid first)" } else { "" }
            [$"kanata not running($hint) — run: ($cmd)"]
        }
        _ => []
    }
}

def doctor-darwin [] {
    let bin = "/usr/local/bin/kanata"
    let vhid_label = "org.pqrs.Karabiner-VirtualHIDDevice-Daemon"
    let vhid_issues = (check-vhid $vhid_label)
    let vhid_ok = $vhid_issues | is-empty

    let issues = (
        (check-bin $bin)
        | append (check-sock-dir)
        | append (check-cfg ($env.HOME | path join ".config/kanata/darwin.kbd"))
        | append $vhid_issues
        | append (check-kanata "org.nixos.kanata" $bin $vhid_ok)
    )

    if ($issues | is-empty) { return }
    report $issues
}

def doctor-linux [] {
    let status = do { ^systemctl status kanata-laptop.service } | complete
    let svc_issues = if $status.exit_code == 4 {
        ["kanata service not found — rebuild NixOS: just nixos"]
    } else if ($status.stdout | str contains "inactive") or ($status.stdout | str contains "failed") {
        ["kanata not running — run: sudo systemctl restart kanata-laptop.service"]
    } else { [] }

    let issues = (
        $svc_issues
        | append (check-cfg ($env.HOME | path join ".config/kanata/core.kbd"))
    )

    if ($issues | is-empty) { return }
    report $issues
}

def report [issues: list<string>] {
    print "kanata:"
    $issues | each {|i| print $"  ($i)" } | ignore
    exit 1
}

#!/usr/bin/env nu

def main [] {
    match (^uname -s | str trim) {
        "Darwin" => { doctor-darwin }
        "Linux"  => { doctor-linux }
        $os      => { print $"kanata: unsupported OS ($os)"; exit 1 }
    }
}

# Returns {state: string} where state is one of:
#   running | stopped | not-loaded | codesigning-killed
def launchd-state [label: string] {
    let out = (do { ^launchctl print $"system/($label)" } | complete)
    if $out.exit_code != 0                                      { return {state: "not-loaded"} }
    if ($out.stdout | str contains "state = running")           { return {state: "running"} }
    if ($out.stdout | str contains "OS_REASON_CODESIGNING")     { return {state: "codesigning-killed"} }
    {state: "stopped"}
}

def restart-cmd [label: string] {
    $"sudo launchctl stop ($label) && sudo launchctl start ($label)"
}

def check-bin [bin: string]: nothing -> list<string> {
    if not ($bin | path exists) { return ["binary missing — run: just darwin"] }
    let sig = (do { ^codesign -d --verbose=2 $bin } | complete)
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

def check-kanata [label: string, bin: string, vhid_running: bool]: nothing -> list<string> {
    let s = (launchd-state $label)
    let cmd = (restart-cmd $label)
    match $s.state {
        "not-loaded"         => ["kanata service not loaded — run: just darwin"]
        "codesigning-killed" => [$"killed by codesigning — fix: sudo codesign --force --sign - ($bin), then re-grant Input Monitoring"]
        "stopped" => {
            let hint = if not $vhid_running { " (start karabiner-vhid first)" } else { "" }
            [$"kanata not running($hint) — run: ($cmd)"]
        }
        _ => []
    }
}

def doctor-darwin [] {
    let bin         = "/usr/local/bin/kanata"
    let vhid_label  = "org.pqrs.Karabiner-VirtualHIDDevice-Daemon"
    let vhid_issues = (check-vhid $vhid_label)
    let vhid_ok     = ($vhid_issues | is-empty)

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
    let status = (do { ^systemctl status kanata-laptop.service } | complete)
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

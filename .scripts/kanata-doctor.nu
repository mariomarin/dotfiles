#!/usr/bin/env nu
# Kanata doctor: report problems with actionable fixes

def main [] {
    let os = (^uname -s | str trim)
    match $os {
        "Darwin" => { doctor-darwin }
        "Linux" => { doctor-linux }
        _ => { print $"kanata: unsupported OS ($os)"; exit 1 }
    }
}

def doctor-darwin [] {
    mut issues = []

    # Binary exists at stable path
    let bin = "/usr/local/bin/kanata"
    if not ($bin | path exists) {
        $issues = ($issues | append "binary missing — run: just darwin")
        report $issues; return
    }

    # Code signing (linker-signed gets rejected)
    let sig = (do { ^codesign -d --verbose=2 $bin } | complete)
    if ($sig.stderr | str contains "linker-signed") {
        $issues = ($issues | append $"bad signature \(linker-signed\) — run: sudo codesign --force --sign - ($bin)")
    }

    # Karabiner daemon running
    let vhid = (do { ^launchctl print system/org.pqrs.Karabiner-VirtualHIDDevice-Daemon } | complete)
    if $vhid.exit_code != 0 or not ($vhid.stdout | str contains "state = running") {
        $issues = ($issues | append "karabiner-vhid not running — run: sudo launchctl kickstart -k system/org.pqrs.Karabiner-VirtualHIDDevice-Daemon")
    }

    # Kanata daemon state
    let kanata = (do { ^launchctl print system/org.nixos.kanata } | complete)
    if $kanata.exit_code != 0 {
        $issues = ($issues | append "kanata service not loaded — run: just darwin")
    } else {
        if ($kanata.stdout | str contains "OS_REASON_CODESIGNING") {
            $issues = ($issues | append $"killed by codesigning — fix: sudo codesign --force --sign - ($bin), then re-grant Input Monitoring")
        } else if not ($kanata.stdout | str contains "state = running") {
            $issues = ($issues | append "kanata not running — run: sudo launchctl kickstart -k system/org.nixos.kanata")
        }
    }

    # Karabiner socket directory
    let sock_dir = "/Library/Application Support/org.pqrs/tmp"
    if not ($sock_dir | path exists) {
        $issues = ($issues | append $"socket dir missing — run: sudo mkdir -p '($sock_dir)' && sudo chmod 1777 '($sock_dir)'")
    }

    # Config file exists
    let cfg = ($env.HOME | path join ".config/kanata/darwin.kbd")
    if not ($cfg | path exists) {
        $issues = ($issues | append "config missing — run: chezmoi apply")
    }

    report $issues
}

def doctor-linux [] {
    mut issues = []

    # Check if kanata service exists
    let status = (do { ^systemctl status kanata-laptop.service } | complete)
    if $status.exit_code == 4 {
        $issues = ($issues | append "kanata service not found — rebuild NixOS: just nixos")
    } else if ($status.stdout | str contains "inactive") or ($status.stdout | str contains "failed") {
        $issues = ($issues | append "kanata not running — run: sudo systemctl restart kanata-laptop.service")
    }

    # Config file exists
    let cfg = ($env.HOME | path join ".config/kanata/core.kbd")
    if not ($cfg | path exists) {
        $issues = ($issues | append "config missing — run: chezmoi apply")
    }

    report $issues
}

def report [issues: list<string>] {
    if ($issues | is-empty) { return }
    print "kanata:"
    $issues | each {|i| print $"  ($i)" } | ignore
    exit 1
}

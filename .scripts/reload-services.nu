#!/usr/bin/env nu
# Service reload functions for chezmoi run_onchange scripts
# Tracks checksums to only reload services whose configs changed

use adt.nu [ok, err, is-ok, is-err, run-cmd]

const STATE_FILE = "~/.cache/chezmoi-service-checksums.nuon"

# Load previous checksums from state file
def load-state [] {
    let path = $STATE_FILE | path expand
    if ($path | path exists) { open $path } else { {} }
}

# Save checksums to state file
def save-state [state: record] {
    let path = $STATE_FILE | path expand
    mkdir ($path | path dirname)
    $state | save -f $path
}

# Check if service config changed
def has-changed [name: string, hash: string, state: record] {
    ($state | get -o $name | default "") != $hash
}

# Check if process is running via pgrep
def is-running-pgrep [process: string]: nothing -> bool {
    run-cmd {pgrep -x $process} | is-ok
}

# Reload a launchctl service (macOS)
def reload-launchctl [service: string]: nothing -> record {
    let process = $service | split row "." | last
    if not (is-running-pgrep $process) {
        return (ok {skipped: "not running"})
    }
    let uid = id -u | str trim
    let is_system = (run-cmd {sudo launchctl list $service} | is-ok)
    let domain = if $is_system {"system"} else {$"gui/($uid)"}
    let result = (run-cmd {sudo launchctl kickstart -k $"($domain)/($service)"})
    if ($result | is-err) {
        return (err $result.error.stderr)
    }
    ok {}
}

# Reload a systemctl service (Linux)
def reload-systemctl [service: string, --user]: nothing -> record {
    let scope = if $user {[--user]} else {[]}
    let enabled = (run-cmd {systemctl ...$scope is-enabled $service})
    if ($enabled | is-err) {return (ok {skipped: "not enabled"})}

    if $user {
        run-cmd {systemctl --user daemon-reload} | ignore
    }

    let result = if $user {
        run-cmd {systemctl --user restart $service}
    } else {
        run-cmd {sudo systemctl restart $service}
    }
    if ($result | is-err) {return (err $result.error.stderr)}
    ok {}
}

# Reload a service by running a command (generic)
def reload-command [check: string, reload: string, name: string]: nothing -> record {
    let running = (run-cmd {nu -c $check})
    if ($running | is-err) {
        return (ok {skipped: "not running"})
    }
    let result = (run-cmd {nu -c $reload})
    if ($result | is-err) {
        return (err $result.error.stderr)
    }
    ok {}
}

# Reload Windows task-based service
def reload-windows-task [task: string, exe: string]: nothing -> record {
    let running = (run-cmd {tasklist /FI $"IMAGENAME eq ($exe)" /NH})
    if ($running | is-err) or ($running.value.stdout | str contains "INFO:") {
        return (ok {skipped: "not running"})
    }
    taskkill /IM $exe /F | ignore
    sleep 1sec

    let task_check = (run-cmd {schtasks /Query /TN $task})
    if ($task_check | is-ok) {
        let result = (run-cmd {schtasks /Run /TN $task})
        if ($result | is-err) {
            return (err $result.error.stderr)
        }
    } else {
        let exe_path = $env.LOCALAPPDATA | path join "kanata" "kanata.exe"
        let config_path = $env.USERPROFILE | path join ".config" "kanata" "windows.kbd"
        if not ($exe_path | path exists) {
            return (err $"executable not found at ($exe_path)")
        }
        conhost --headless $exe_path --cfg $config_path
    }
    ok {}
}

# Process a single service - reload if changed
def process-service [svc: record, state: record] {
    let name = $svc.name
    let hash = $svc.hash
    let prev_hash = $state | get -o $name | default ""

    if not (has-changed $name $hash $state) {
        return {name: $name, hash: $hash}
    }

    let result = match $svc.type {
        "launchctl" => { reload-launchctl $svc.service }
        "systemctl" => { reload-systemctl $svc.service }
        "systemctl-user" => { reload-systemctl $svc.service --user }
        "command" => { reload-command $svc.check $svc.reload $name }
        "windows-task" => {reload-windows-task $svc.task $svc.exe}
        _ => {err $"unknown type: ($svc.type)"}
    }

    if ($result | is-ok) and ($result.value | get -o "skipped" | is-not-empty) {
        return {name: $name, hash: $hash}
    }

    if ($result | is-err) {
        print -e $"✗ ($name): ($result.error)"
        return {name: $name, hash: $prev_hash}
    }

    {name: $name, hash: $hash}
}

# Main - receives services as JSON from template
def main [--services: string] {
    let svcs = $services | from json
    let state = (load-state)

    let results = $svcs | each {|svc| process-service $svc $state }

    # Update state with new checksums
    let new_state = $results | reduce -f $state {|it, acc| $acc | upsert $it.name $it.hash }
    save-state $new_state
}

#!/usr/bin/env nu
# Service reload functions for chezmoi run_onchange scripts
# Tracks checksums to only reload services whose configs changed

const STATE_FILE = "~/.cache/chezmoi-service-checksums.nuon"

# Load previous checksums from state file
def load-state [] {
    let path = ($STATE_FILE | path expand)
    if ($path | path exists) { open $path } else { {} }
}

# Save checksums to state file
def save-state [state: record] {
    let path = ($STATE_FILE | path expand)
    mkdir ($path | path dirname)
    $state | save -f $path
}

# Get value from record or null if missing
def get-or-null [key: string] {
    let input = $in
    if ($key in $input) { $input | get $key } else { null }
}

# Check if service config changed
def has-changed [name: string, hash: string, state: record] {
    let prev = ($state | get-or-null $name | default "")
    $prev != $hash
}

# Check if process is running via pgrep
def is-running-pgrep [process: string] {
    (do { pgrep -x $process } | complete).exit_code == 0
}

# Reload a launchctl service (macOS)
def reload-launchctl [service: string] {
    let process = ($service | split row "." | last)
    if not (is-running-pgrep $process) {
        return { ok: true, skipped: "not running" }
    }
    let stop = (do { sudo launchctl stop $service } | complete)
    if $stop.exit_code != 0 {
        return { ok: false, error: $stop.stderr }
    }
    sleep 1sec
    let start = (do { sudo launchctl start $service } | complete)
    if $start.exit_code != 0 {
        return { ok: false, error: $start.stderr }
    }
    { ok: true }
}

# Reload a systemctl service (Linux)
def reload-systemctl [service: string, --user] {
    let scope = if $user { [--user] } else { [] }
    let enabled = (do { systemctl ...$scope is-enabled $service } | complete)
    if $enabled.exit_code != 0 { return { ok: true, skipped: "not enabled" } }

    if $user { do { systemctl --user daemon-reload } | complete | ignore }

    let result = if $user {
        do { systemctl --user restart $service } | complete
    } else {
        do { sudo systemctl restart $service } | complete
    }
    if $result.exit_code != 0 { return { ok: false, error: $result.stderr } }
    { ok: true }
}

# Reload a service by running a command (generic)
def reload-command [check: string, reload: string, name: string] {
    let running = (do { nu -c $check } | complete)
    if $running.exit_code != 0 {
        return { ok: true, skipped: "not running" }
    }
    let result = (do { nu -c $reload } | complete)
    if $result.exit_code != 0 {
        return { ok: false, error: $result.stderr }
    }
    { ok: true }
}

# Reload Windows task-based service
def reload-windows-task [task: string, exe: string] {
    let running = (do { tasklist /FI $"IMAGENAME eq ($exe)" /NH } | complete)
    if $running.exit_code != 0 or ($running.stdout | str contains "INFO:") {
        return { ok: true, skipped: "not running" }
    }
    taskkill /IM $exe /F | ignore
    sleep 1sec

    let task_exists = (do { schtasks /Query /TN $task } | complete).exit_code == 0
    if $task_exists {
        let result = (do { schtasks /Run /TN $task } | complete)
        if $result.exit_code != 0 {
            return { ok: false, error: $result.stderr }
        }
    } else {
        let exe_path = ($env.LOCALAPPDATA | path join "kanata" "kanata.exe")
        let config_path = ($env.USERPROFILE | path join ".config" "kanata" "windows.kbd")
        if not ($exe_path | path exists) {
            return { ok: false, error: $"executable not found at ($exe_path)" }
        }
        conhost --headless $exe_path --cfg $config_path
    }
    { ok: true }
}

# Process a single service - reload if changed
def process-service [svc: record, state: record] {
    let name = $svc.name
    let hash = $svc.hash
    let prev_hash = ($state | get-or-null $name | default "")

    if not (has-changed $name $hash $state) {
        return { name: $name, hash: $hash }
    }

    let result = match $svc.type {
        "launchctl" => { reload-launchctl $svc.service }
        "systemctl" => { reload-systemctl $svc.service }
        "systemctl-user" => { reload-systemctl $svc.service --user }
        "command" => { reload-command $svc.check $svc.reload $name }
        "windows-task" => { reload-windows-task $svc.task $svc.exe }
        _ => { { ok: false, error: $"unknown type: ($svc.type)" } }
    }

    if ($result | get-or-null "skipped" | is-not-empty) {
        return { name: $name, hash: $hash }
    }

    if not $result.ok {
        print -e $"✗ ($name): ($result.error)"
        return { name: $name, hash: $prev_hash }
    }

    { name: $name, hash: $hash }
}

# Main - receives services as JSON from template
def main [--services: string] {
    let svcs = ($services | from json)
    let state = (load-state)

    let results = ($svcs | each {|svc| process-service $svc $state })

    # Update state with new checksums
    let new_state = ($results | reduce -f $state {|it, acc| $acc | upsert $it.name $it.hash })
    save-state $new_state
}

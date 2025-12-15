#!/usr/bin/env nu
# Service reload functions for chezmoi run_onchange scripts

# Reload a launchctl service (macOS)
# Uses pgrep to check if running (avoids sudo for check)
def reload-launchctl [service: string] {
    # Extract process name from service ID (e.g., org.nixos.kanata -> kanata)
    let process = ($service | split row "." | last)
    let running = (do { pgrep -x $process } | complete).exit_code == 0
    if not $running {
        print $"($service) not running, skipping"
        return
    }
    print $"Reloading ($service)..."
    sudo launchctl stop $service
    sleep 1sec
    sudo launchctl start $service
    print $"✓ ($service) reloaded"
}

# Reload a systemctl service (Linux)
def reload-systemctl [service: string] {
    let active = (do { systemctl is-active $service } | complete).exit_code == 0
    if not $active {
        print $"($service) not active, skipping"
        return
    }
    print $"Reloading ($service)..."
    sudo systemctl restart $service
    print $"✓ ($service) reloaded"
}

# Reload a service by running a command (generic)
def reload-command [
    check: string  # Command to check if running
    reload: string # Command to reload
    name: string   # Display name
] {
    let running = (do { nu -c $check } | complete).exit_code == 0
    if not $running {
        print $"($name) not running, skipping"
        return
    }
    print $"Reloading ($name)..."
    nu -c $reload
    print $"✓ ($name) reloaded"
}

# Reload Windows task-based service
def reload-windows-task [task: string, exe: string] {
    let running = (do { tasklist | find $exe } | complete).exit_code == 0
    if not $running {
        print $"($task) not running, skipping"
        return
    }

    print $"Stopping ($task)..."
    taskkill /IM $exe /F | ignore
    sleep 1sec

    let task_exists = (do { schtasks /Query /TN $task } | complete).exit_code == 0
    if $task_exists {
        print $"Starting ($task) via scheduled task..."
        schtasks /Run /TN $task
    } else {
        let exe_path = ($env.LOCALAPPDATA | path join "kanata" "kanata.exe")
        let config_path = ($env.USERPROFILE | path join ".config" "kanata" "windows.kbd")
        if ($exe_path | path exists) {
            print $"Starting ($task) directly..."
            conhost --headless $exe_path --cfg $config_path
        } else {
            print $"($task) executable not found at ($exe_path)"
            return
        }
    }
    print $"✓ ($task) reloaded"
}

# Main dispatcher - call with service definition from YAML
def main [
    --type: string
    --service: string = ""
    --task: string = ""
    --exe: string = ""
    --check: string = ""
    --reload: string = ""
    --name: string = ""
] {
    match $type {
        "launchctl" => { reload-launchctl $service }
        "systemctl" => { reload-systemctl $service }
        "command" => { reload-command $check $reload $name }
        "windows-task" => { reload-windows-task $task $exe }
        _ => { print $"Unknown service type: ($type)" }
    }
}

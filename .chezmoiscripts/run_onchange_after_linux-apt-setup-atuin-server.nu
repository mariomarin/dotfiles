#!/usr/bin/env nu
# Enable and start atuin sync server systemd service
# Only runs on linux-apt platform (devbox)

# Check if atuin and systemctl are available
if (which atuin | is-empty) or (which systemctl | is-empty) {
    exit 0
}

# Check if systemd user bus is available
let bus_check = (do -i { systemctl --user status } | complete)
if $bus_check.exit_code != 0 {
    print "⚠️  Systemd user bus not available"
    print "   Run manually after login: systemctl --user enable --now atuin-server.service"
    exit 0
}

# Check if service file changed
let needs_reload = (
    do -i { systemctl --user show atuin-server.service --property=NeedDaemonReload --value }
    | complete
    | get stdout
    | str trim
) == "yes"

# Check if service is active
let is_active = (
    do -i { systemctl --user is-active atuin-server.service }
    | complete
    | get exit_code
) == 0

# Reload systemd if needed
if $needs_reload {
    systemctl --user daemon-reload
}

# Enable service if not already enabled
if (do -i { systemctl --user is-enabled atuin-server.service } | complete | get exit_code) != 0 {
    print "Enabling atuin sync server..."
    systemctl --user enable atuin-server.service
}

# Start or restart service if needed
if not $is_active {
    print "Starting atuin sync server..."
    systemctl --user start atuin-server.service
    print "✓ Atuin sync server started"
} else if $needs_reload {
    print "Restarting atuin sync server (service file changed)..."
    systemctl --user restart atuin-server.service
    print "✓ Atuin sync server restarted"
}

# Verify server is running
let status = (systemctl --user is-active atuin-server.service | str trim)
if $status == "active" {
    print "✓ Atuin sync server is running on 127.0.0.1:8888"
} else {
    print "⚠️  Atuin sync server failed to start"
    print "   Check logs: journalctl --user -u atuin-server -f"
}

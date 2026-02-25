#!/usr/bin/env nu
# Enable and start atuin daemon systemd service

if (which atuin | is-not-empty) and (which systemctl | is-not-empty) {
    # Check if service file changed before reloading
    let needs_reload = (do -i { systemctl --user show atuin.service --property=NeedDaemonReload --value } | complete | get stdout | str trim) == "yes"

    # Check if service is active
    let is_active = (do -i { systemctl --user is-active atuin.service } | complete | get exit_code) == 0

    # Reload systemd to pick up any service file changes
    if $needs_reload {
        systemctl --user daemon-reload
    }

    # Enable service if not already enabled
    if (do -i { systemctl --user is-enabled atuin.service } | complete | get exit_code) != 0 {
        print "Enabling atuin daemon service..."
        systemctl --user enable atuin.service
    }

    # Start or restart service if needed
    if not $is_active {
        print "Starting atuin daemon service..."
        systemctl --user start atuin.service
        print "✓ Atuin daemon service started"
    } else if $needs_reload {
        print "Restarting atuin daemon service (service file changed)..."
        systemctl --user restart atuin.service
        print "✓ Atuin daemon service restarted"
    }
}

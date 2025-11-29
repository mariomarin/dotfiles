#!/usr/bin/env nu
# Enable systemd user services (Linux)

# Enable and start battery monitor service if the script and service file exist
let battery_script = ("~/.config/polybar/battery-combined-udev.sh" | path expand)
let battery_service = ("~/.config/systemd/user/battery-combined-udev.service" | path expand)

if ($battery_script | path exists) and (ls -l $battery_script | get 0.mode | str starts-with "-rwx") and ($battery_service | path exists) {
    print "Enabling battery-combined-udev service..."
    systemctl --user daemon-reload
    systemctl --user enable battery-combined-udev.service
    print "Battery monitor service enabled"
} else {
    print "Battery script or service file not found - skipping service enablement"
}

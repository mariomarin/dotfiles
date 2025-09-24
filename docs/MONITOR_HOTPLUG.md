# Monitor Hotplug Configuration

This document describes the automatic monitor detection and configuration setup.

## Overview

The system uses **autorandr** to automatically detect and configure displays when monitors are connected or disconnected.

## Components

### 1. Autorandr

Autorandr automatically:

- Detects monitor changes
- Applies saved display configurations
- Runs scripts after configuration changes

### 2. Postswitch Hook

Location: `~/.config/autorandr/postswitch`

This script runs after any display configuration change and:

- Restarts polybar to adapt to new monitors
- Resets wallpapers on all displays
- Restarts picom for proper compositing
- Shows a notification

### 3. Display Profiles

Save display configurations:

```bash
# Save current setup with a name
autorandr --save home
autorandr --save office
autorandr --save laptop-only

# List saved profiles
autorandr

# Manually switch profiles
autorandr office
```

## How It Works

1. **Monitor connected/disconnected** → udev event
2. **Autorandr detects change** → matches saved profile
3. **Profile applied** → xrandr commands executed
4. **Postswitch script runs** → services restarted

## Common Scenarios

### Laptop + External Monitor

```bash
# Connect monitor, arrange displays
xrandr --output HDMI1 --right-of eDP1 --auto

# Save configuration
autorandr --save docked
```

### Laptop Only

```bash
# Disconnect external monitors
autorandr --save mobile
```

### Presentation Mode

```bash
# Mirror displays
xrandr --output HDMI1 --same-as eDP1 --auto
autorandr --save presentation
```

## Manual Configuration

If autorandr doesn't detect your setup:

```bash
# Force detection
autorandr --change

# Skip profiles, just detect
autorandr --default default

# Debug mode
autorandr --debug
```

## Alternative: Using systemd

For systems where autorandr doesn't work well, use systemd path units:

1. Monitor for changes in `/sys/class/drm/`
2. Trigger service on change
3. Service runs display configuration script

## Troubleshooting

### Polybar not appearing on new monitor

1. Check if polybar restarted: `systemctl --user status polybar`
2. Check logs: `journalctl --user -u polybar -f`
3. Manually restart: `systemctl --user restart polybar`

### Wrong resolution/arrangement

1. Delete bad profile: `autorandr --remove PROFILE`
2. Reconfigure displays manually
3. Save new profile: `autorandr --save PROFILE`

### Autorandr not detecting changes

1. Check udev rules: `ls /etc/udev/rules.d/*autorandr*`
2. Install autorandr udev rules if missing
3. Reload udev: `sudo udevadm control --reload`

## Integration with LeftWM

LeftWM automatically handles workspace assignment to monitors. The polybar restart ensures bars appear on all active displays.

## Related Documentation

- [LeftWM CLAUDE.md](../private_dot_config/leftwm/CLAUDE.md)
- [Autorandr GitHub](https://github.com/phillipberndt/autorandr)

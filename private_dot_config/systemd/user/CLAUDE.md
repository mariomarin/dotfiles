# CLAUDE.md - Systemd User Services

This directory contains systemd user service units managed by chezmoi.

## Current Services

### battery-combined-udev.service

- **Purpose**: Battery monitoring for Polybar
- **Script**: `~/.config/polybar/battery-combined-udev.sh`
- **Type**: Simple service with automatic restart
- **Activation**: Enabled via chezmoi script

## Service Management

### Check Service Status

```bash
systemctl --user status battery-combined-udev
```

### Enable/Disable Services

```bash
systemctl --user enable battery-combined-udev.service
systemctl --user disable battery-combined-udev.service
```

### Start/Stop Services

```bash
systemctl --user start battery-combined-udev
systemctl --user stop battery-combined-udev
```

### View Logs

```bash
journalctl --user -u battery-combined-udev -f
```

## Adding New Services

1. Create service file in this directory
2. Use `%h` for home directory in ExecStart paths
3. Set appropriate dependencies (e.g., `After=graphical-session.target`)
4. Update `.chezmoiscripts/run_onchange_enable-user-services.sh.tmpl` if auto-enable is needed

## Service File Template

```ini
[Unit]
Description=Service Description
After=graphical-session.target

[Service]
Type=simple
ExecStart=%h/path/to/script
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
```

## Integration with Desktop

These services complement desktop autostart files:

- Services: For background daemons and monitoring
- Autostart: For GUI applications

## Important Notes

- Services are enabled by chezmoi scripts, not manually
- Use `systemctl --user daemon-reload` after adding new services
- Check script permissions - must be executable
- Services run in user context, not system-wide

# CLAUDE.md - Polybar Configuration

This directory contains Polybar-related scripts managed by chezmoi.

## Current Scripts

### battery-combined-udev.sh

- **Purpose**: Monitor battery status using udev events
- **Usage**: Run as systemd user service
- **Service**: `battery-combined-udev.service`
- **Features**: Combines multiple battery monitoring

## Integration

### Systemd Service

The battery script runs as a systemd user service instead of being launched from window manager startup scripts.

### External Dependencies

- `pulseaudio-control`: Managed via chezmoi external in `~/.local/bin/`
- Not duplicated in this directory

## Polybar Module Configuration

Polybar configuration files should reference:

- Local scripts: `~/.config/polybar/script-name.sh`
- External tools: `~/.local/bin/tool-name`

## Adding New Scripts

1. Create executable script in this directory
2. Use `executable_` prefix for chezmoi (e.g., `executable_script.sh`)
3. Consider if it should be:
   - A systemd service (for daemons)
   - Called directly by polybar modules
   - An external dependency

## Best Practices

- Use absolute paths in scripts
- Make scripts POSIX-compliant when possible
- Add error handling and logging
- Document script dependencies

## Related Configuration

- Polybar config: Usually in window manager themes (e.g., `~/.config/leftwm/themes/*/polybar.config`)
- Systemd services: `~/.config/systemd/user/`
- External tools: `~/.local/bin/` via chezmoi externals

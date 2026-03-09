# CLAUDE.md - Systemd User Services

This directory contains systemd user service units managed by chezmoi.

## Current Services

### atuin-server.service

- **Purpose**: Atuin self-hosted sync server
- **Documentation**: https://docs.atuin.sh/self-hosting/server-setup/
- **Type**: Simple service with automatic restart
- **Executable**: `~/.local/bin/atuin server start`
- **Port**: 8888 (localhost only)
- **Platform**: linux-apt only
- **Note**: Client daemon started by shell (`atuin init zsh`), not systemd
- **Security**: Hardened with PrivateTmp, NoNewPrivileges, ProtectSystem

### clipper.service

- **Purpose**: Clipboard service for remote clipboard access over SSH
- **Documentation**: https://github.com/wincent/clipper
- **Type**: Simple service with automatic restart
- **Port**: 8377 (TCP on 127.0.0.1)
- **Auto-enabled**: Via symlink in `default.target.wants/`
- **Security**: Hardened with PrivateTmp, NoNewPrivileges, ProtectSystem
- **Installation**: Requires `clipper` package (available via Homebrew on macOS, or build from source on Linux)

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

```systemd
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

## Installing Clipper on Apt-Based Systems

Clipper requires manual installation on Ubuntu/Debian systems:

### Option 1: Install Pre-built Binary (Recommended)

```bash
# Download latest release from GitHub
cd /tmp
wget https://github.com/wincent/clipper/releases/latest/download/clipper-linux-amd64

# Install to user bin directory (no sudo needed)
# Note: ~/.local/bin is already in PATH via zsh/chezmoi config
mkdir -p ~/.local/bin
mv clipper-linux-amd64 ~/.local/bin/clipper
chmod +x ~/.local/bin/clipper

# Apply chezmoi (installs systemd service)
chezmoi apply

# Enable and start service
systemctl --user daemon-reload
systemctl --user enable clipper.service
systemctl --user start clipper.service

# Verify it's running
systemctl --user status clipper.service
lsof -i :8377  # Should show clipper listening
```

### Option 2: Build from Source

```bash
# Install Go (if not already installed)
sudo apt install golang-go

# Build and install Clipper
git clone https://github.com/wincent/clipper.git
cd clipper
go build

# Install to user bin directory
# Note: ~/.local/bin is already in PATH via zsh/chezmoi config
mkdir -p ~/.local/bin
cp clipper ~/.local/bin/
chmod +x ~/.local/bin/clipper

# Follow the rest of Option 1 steps above
```

### Option 3: System-wide Install (Alternative)

If you prefer a system-wide installation accessible to all users:

```bash
# Download and install to /usr/bin
cd /tmp
wget https://github.com/wincent/clipper/releases/latest/download/clipper-linux-amd64
sudo mv clipper-linux-amd64 /usr/bin/clipper
sudo chmod +x /usr/bin/clipper

# Modify systemd service to use /usr/bin/clipper
# Edit ~/.config/systemd/user/clipper.service and change:
# ExecStart=%h/.local/bin/clipper to ExecStart=/usr/bin/clipper

# Then enable as usual
systemctl --user daemon-reload
systemctl --user enable --now clipper.service
```

### Verify Installation

```bash
# Test clipboard integration
echo "Hello from clipper!" | nc localhost 8377
# Paste should now work (Ctrl+V or middle-click)

# View logs
journalctl --user -u clipper -f
```

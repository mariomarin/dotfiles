# CLAUDE.md - Kanata Configuration

This directory contains Kanata configuration for advanced keyboard remapping.

## Directory Structure

```text
private_dot_config/kanata/
├── CLAUDE.md        # This file - AI guidance
├── README.md        # User documentation
├── laptop.kbd       # Linux/NixOS configuration
├── darwin.kbd       # macOS configuration
└── windows.kbd      # Windows configuration
```

## Configuration Philosophy

- **Ergonomics First**: Reduce hand movement and finger strain
- **Vim-Compatible**: Support efficient text editing workflows
- **Non-Intrusive**: Keep standard typing experience intact
- **Layered Approach**: Use layers for additional functionality

## Key Mappings

See [KEYBINDINGS.md](KEYBINDINGS.md) for complete key mapping reference and optional features.

## Platform Support

Kanata is available on all desktop platforms:

### Linux (NixOS)

- Configured as systemd service in `nixos/modules/services/kanata.nix`
- Uses `uinput` for input/output
- Requires `input` and `uinput` groups

### macOS (nix-darwin)

- Configured in `nix/darwin/modules/kanata.nix`
- Packages in `nix/darwin/modules/packages.nix` (kanata, karabiner-dk)
- Three LaunchDaemons: vhidmanager, vhiddaemon, kanata
- Logs: `/tmp/kanata.*.log`, `/tmp/karabiner-*.log`

**Architecture:**

```text
┌─────────────────────┐
│  Physical Keyboard  │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│ Karabiner DriverKit │  (system extension, activated once)
│   VirtualHIDDevice  │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│ karabiner-vhiddaemon│  (LaunchDaemon, runs continuously)
│   creates socket    │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│       kanata        │  (LaunchDaemon, connects to socket)
│  keyboard remapper  │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│  Virtual Keyboard   │  (output to macOS)
└─────────────────────┘
```

**First-time setup requires manual activation:**

```bash
sudo "/Applications/Nix Apps/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" activate
```

This can't run from `/nix/store` - macOS requires `/Applications` for system extensions.

### Windows

- Manual installation required (not available via winget)
- Requires Interception driver
- Uses `low-level-hook` for input, `send-event-sink` for output
- Can be configured to run at startup via Task Scheduler

## Common Tasks

### Testing Configuration

Before applying system-wide:

```bash
sudo kanata -d ~/.config/kanata/laptop.kbd
```

### Finding Keyboard Device

**Linux:**

```bash
ls -la /dev/input/by-path/ | grep kbd
```

**macOS:**

```bash
ioreg -c IOHIDKeyboard -r | grep -i "Product"
```

**Windows:**

Uses `low-level-hook` - no device path needed.

### Debugging

**Linux:**

```bash
journalctl -u kanata-laptop -f
```

**macOS:**

```bash
# Check service status
sudo launchctl list | grep -E 'kanata|karabiner'

# View logs
tail -f /tmp/kanata.out.log /tmp/kanata.err.log

# Restart services
sudo launchctl stop org.nixos.kanata && sudo launchctl start org.nixos.kanata
```

## Important Notes

**Linux:**

- Kanata requires kernel module `uinput`
- User must be in `input` and `uinput` groups
- Device paths may vary between systems

**macOS:**

- Karabiner driver extension must be activated once from `/Applications`
- Cannot activate from `/nix/store` (macOS security restriction)
- Emergency exit: `lctl+spc+esc` (physical keys)
- vhidmanager exit code 1 is normal after initial activation

**General:**

- Disable conflicting services (Karabiner-Elements, interception-tools)

## Related Documentation

- [KEYBINDINGS.md](KEYBINDINGS.md) - Complete keybinding reference
- [README.md](README.md) - Configuration overview and installation
- [Kanata Documentation](https://github.com/kanata/kanata) - Official documentation
- [Keyboard Layout Reference](https://github.com/kanata/kanata/blob/master/doc/quick-reference.md)
- [Example Configurations](https://github.com/kanata/kanata/tree/master/keymap)

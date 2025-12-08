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

### macOS (darwin)

- Installed via nix-darwin (`nix/darwin/modules/packages.nix`)
- Requires Karabiner DriverKit VirtualHIDDevice
- Uses `iokit-name` for input, `kext` for output
- Run manually or via LaunchAgent

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

Check service logs:

```bash
journalctl -u kanata-laptop -f
```

## Important Notes

- Kanata requires kernel module `uinput`
- User must be in `input` and `uinput` groups
- Disable conflicting services (e.g., interception-tools)
- Device paths may vary between systems

## Related Documentation

- [KEYBINDINGS.md](KEYBINDINGS.md) - Complete keybinding reference
- [README.md](README.md) - Configuration overview and installation
- [Kanata Documentation](https://github.com/kanata/kanata) - Official documentation
- [Keyboard Layout Reference](https://github.com/kanata/kanata/blob/master/doc/quick-reference.md)
- [Example Configurations](https://github.com/kanata/kanata/tree/master/keymap)

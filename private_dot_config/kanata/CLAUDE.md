# CLAUDE.md - Kanata Configuration

This directory contains Kanata configuration for advanced keyboard remapping.

## Directory Structure

```text
private_dot_config/kanata/
├── CLAUDE.md        # This file - AI guidance
├── README.md        # User documentation
├── laptop.kbd       # Linux/NixOS configuration
├── darwin.kbd       # macOS configuration (ANSI Spanish LatAm)
└── windows.kbd      # Windows configuration
```

## Hardware Reference

### macOS (malus) - Multiple Keyboards

The darwin.kbd config supports both keyboards by mapping both `grv` and `nubs`:

**MacBook Pro 13" M1 2020 (built-in)**:

- Physical layout: ANSI (horizontal Enter, full-width left Shift)
- Language layout: Spanish Latin American
- Key below Esc: `§ ±` - sends `nubs` keycode (ISO Section, 0x0A)
- Has Ñ key: Yes (right of L)

**Kinesis Advantage (external)**:

- Physical layout: ANSI
- Language layout: US
- Key below Esc: `` ` ~ `` - sends `grv` keycode (Grave, 0x32)

**Key insight**: Although the MacBook is physically ANSI, Apple uses the ISO `nubs` keycode for the
`§±` key on international layouts. The config maps both keys to the accent layer trigger.

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
- Uses stable path `/run/current-system/sw/bin/kanata` for Input Monitoring permission persistence
- Logs: `/tmp/kanata.out.log`, `/tmp/kanata.err.log`

**Architecture:**

```text
Physical Keyboard → Karabiner DriverKit Extension → kanata → Virtual Keyboard
                    (system extension)              (LaunchDaemon)
```

**First-time setup:**

1. Activate extension (once):
   `sudo "/Applications/Nix Apps/.Karabiner-VirtualHIDDevice-Manager.app/.../Karabiner-VirtualHIDDevice-Manager" activate`
2. Approve in System Settings > Privacy & Security
3. Grant Input Monitoring to `/run/current-system/sw/bin/kanata`

### Windows

- Manual installation required (not available via winget)
- Requires Interception driver
- Uses `low-level-hook` for input, `send-event-sink` for output
- Can be configured to run at startup via Task Scheduler

## Hammerspoon Integration (macOS)

Kanata's window layer (= key) integrates with Hammerspoon for workspace management on macOS.

### Architecture

```text
Physical Keyboard → Kanata → Hammerspoon → macOS Spaces API
                    (sends     (intercepts    (switches
                   Ctrl+Alt)   Ctrl+Alt)       spaces)
```

### Setup

1. **Install Hammerspoon**: Already in `Brewfile`, install with `brew bundle`
2. **Config location**: `~/.config/hammerspoon/init.lua` (managed by chezmoi, auto-reloads on change)
   - Hammerspoon configured to use XDG path via `defaults write`
3. **Auto-start**: Configured automatically via `run_onchange_after_darwin-brew-setup-hammerspoon.nu`
4. **Grant permissions**: Accessibility permission for Hammerspoon on first launch
5. **Create desktops**: Manually create 9 desktops in Mission Control (macOS doesn't allow programmatic creation)

### Window Layer Keybindings

| User Action | Kanata Sends | Hammerspoon Action |
|-------------|--------------|-------------------|
| `=+1-9` | `Ctrl+Alt+1-9` | Switch to desktop 1-9 |
| `=+Shift+1-9` | `Ctrl+Alt+Shift+1-9` | Move window to desktop 1-9 |
| `=+h` | `Ctrl+Alt+h` | Previous space |
| `=+l` | `Ctrl+Alt+l` | Next space |
| `=+j` | `Ctrl+Alt+j` | Focus window below |
| `=+k` | `Ctrl+Alt+k` | Focus window above |
| `=+w` | `Ctrl+Alt+w` | Swap workspaces (multi-monitor) |
| `=+Shift+,` | `Ctrl+Alt+Shift+,` | Move window to prev monitor |
| `=+Shift+.` | `Ctrl+Alt+Shift+.` | Move window to next monitor |
| `=+i` | `Ctrl+Alt+i` | Show desktop info (debug) |

**Design**: Matches LeftWM keybindings for cross-platform muscle memory.

### Reload Hammerspoon

After editing `~/.hammerspoon/init.lua`:

```bash
# Hammerspoon auto-reloads when files change
# Or manually: open Hammerspoon, click "Reload Config"
```

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
sudo launchctl list | grep kanata

# View logs
tail -f /tmp/kanata.out.log /tmp/kanata.err.log

# Restart service
# nix-darwin:
sudo launchctl kickstart -kp system/org.nixos.kanata
# darwin-brew:
sudo launchctl kickstart -k system/org.local.kanata
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

**General:**

- Disable conflicting services (Karabiner-Elements, interception-tools)

## Related Documentation

- [KEYBINDINGS.md](KEYBINDINGS.md) - Complete keybinding reference
- [README.md](README.md) - Configuration overview and installation
- [Kanata Documentation](https://github.com/kanata/kanata) - Official documentation
- [Keyboard Layout Reference](https://github.com/kanata/kanata/blob/master/doc/quick-reference.md)
- [Example Configurations](https://github.com/kanata/kanata/tree/master/keymap)

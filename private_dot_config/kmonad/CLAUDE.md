# CLAUDE.md - KMonad Configuration

This directory contains KMonad configuration for advanced keyboard remapping.

## Directory Structure

```text
private_dot_config/kmonad/
├── CLAUDE.md        # This file - AI guidance
├── README.md        # User documentation
└── laptop.kbd       # KMonad configuration for laptop keyboard
```

## Configuration Philosophy

- **Ergonomics First**: Reduce hand movement and finger strain
- **Vim-Compatible**: Support efficient text editing workflows
- **Non-Intrusive**: Keep standard typing experience intact
- **Layered Approach**: Use layers for additional functionality

## Key Mappings

### Base Layer Modifications

1. **Caps Lock → Control/Escape**
   - Tap: Escape (for vim)
   - Hold: Control (for shortcuts)

2. **Navigation Layer** (Hold Right Alt)
   - Vim-style arrow keys (hjkl)
   - Home/End/PageUp/PageDown

### Optional Features

The configuration includes commented-out sections for:

- Home row modifiers
- Symbol layers
- Number pad layer

## NixOS Integration

KMonad is configured as a NixOS service in `nixos/modules/services/kmonad.nix`:

- Runs as systemd service
- Reads config from user's home directory
- Requires `input` and `uinput` groups

## Common Tasks

### Testing Configuration

Before applying system-wide:

```bash
sudo kmonad -d ~/.config/kmonad/laptop.kbd
```

### Finding Keyboard Device

```bash
ls -la /dev/input/by-path/ | grep kbd
```

### Debugging

Check service logs:

```bash
journalctl -u kmonad-laptop -f
```

## Important Notes

- KMonad requires kernel module `uinput`
- User must be in `input` and `uinput` groups
- Disable conflicting services (e.g., interception-tools)
- Device paths may vary between systems

## Resources

- [KMonad Documentation](https://github.com/kmonad/kmonad)
- [Keyboard Layout Reference](https://github.com/kmonad/kmonad/blob/master/doc/quick-reference.md)
- [Example Configurations](https://github.com/kmonad/kmonad/tree/master/keymap)

# KMonad Configuration

Advanced keyboard remapping with Carabiner-style keymaps and Space Cadet keyboard emulation for ThinkPad T470.

## Features

- **Tap-Hold Modifiers**: Caps Lock as Control/Escape, Tab as Tab/Hyper
- **Space Cadet Shifts**: Parentheses on tap, Shift on hold
- **Navigation Layer**: Vim-style arrow keys on home row (hold Right Alt)
- **Ergonomic Design**: Reduce hand movement and finger strain
- **Optional Home Row Mods**: Can be enabled for additional ergonomics

## Keybindings

For a complete list of keybindings and layer configurations, see **[KEYBINDINGS.md](KEYBINDINGS.md)**.

**Quick reference**:

- **Caps Lock**: Tap for Escape, hold for Control
- **Tab**: Tap for Tab, hold for Hyper (Ctrl+Meta+Alt)
- **Right Alt + hjkl**: Vim-style navigation
- **Shift keys**: Tap for parentheses, hold for Shift

## Installation

### 1. Add KMonad to NixOS

Add to your `configuration.nix` or appropriate module:

```nix
# Enable KMonad
services.kmonad = {
  enable = true;
  keyboards = {
    laptop = {
      device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
      config = builtins.readFile ./kmonad/laptop.kbd;
    };
  };
};

# Add your user to the input and uinput groups
users.users.mario = {
  extraGroups = [ "input" "uinput" ];
};
```

### 2. Enable uinput module

```nix
boot.kernelModules = [ "uinput" ];
```

### 3. Rebuild NixOS

```bash
sudo nixos-rebuild switch
```

## Customization

### Adding New Layers

1. Define layer toggle in `defalias`:

   ```lisp
   (defalias
     fn_layer (layer-toggle function)
   )
   ```

2. Create the layer definition:

   ```lisp
   (deflayer function
     ... key mappings ...
   )
   ```

### Modifying Tap-Hold Timing

Adjust the timing (in milliseconds) in tap-hold definitions:

```lisp
(tap-hold-next-release 200 esc lctl)  ; 200ms delay
```

### Finding Your Keyboard Device

List available keyboards:

```bash
ls -la /dev/input/by-path/ | grep kbd
```

## Troubleshooting

### KMonad service fails to start

1. Check device permissions:

   ```bash
   ls -la /dev/input/by-path/platform-i8042-serio-0-event-kbd
   ```

2. Verify you're in the `input` and `uinput` groups:

   ```bash
   groups
   ```

3. Check KMonad service logs:

   ```bash
   journalctl -u kmonad-laptop -f
   ```

### Keys not working as expected

1. Test configuration:

   ```bash
   sudo kmonad ~/.config/kmonad/laptop.kbd
   ```

2. Check for syntax errors in the `.kbd` file

## Related Documentation

- [KEYBINDINGS.md](KEYBINDINGS.md) - Complete keybinding reference
- [CLAUDE.md](CLAUDE.md) - AI guidance for KMonad configuration
- [KMonad Documentation](https://github.com/kmonad/kmonad) - Official documentation
- [KMonad Tutorial](https://github.com/kmonad/kmonad/blob/master/keymap/tutorial.kbd) - Tutorial config
- [Karabiner Elements](https://github.com/tekezo/Karabiner-Elements) - macOS inspiration

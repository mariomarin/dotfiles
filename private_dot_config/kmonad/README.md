# KMonad Configuration

Advanced keyboard remapping with Carabiner-style keymaps and Space Cadet keyboard emulation for ThinkPad T470.

## Features

### Primary Remappings

| Physical Key | Mapped To | Description |
| --- | --- | --- |
| Caps Lock | Control/Escape | Tap for Escape, hold for Control |
| Tab | Tab/Hyper | Tap for Tab, hold for Hyper (Ctrl+Meta+Alt) |
| Left Ctrl | {/Ctrl | Tap for {, hold for Control |
| Right Ctrl | }/Ctrl | Tap for }, hold for Control |
| Left Shift | (/Shift | Tap for (, hold for Shift |
| Right Shift | )/Shift | Tap for ), hold for Shift |
| Left Alt | </Alt | Tap for <, hold for Alt (preserves international input) |
| Right Alt | >/Navigation | Tap for >, hold for Navigation layer |

### Navigation Layer (Hold Right Alt)

| Key | Action | Description |
| --- | --- | --- |
| `h` | Left Arrow | Vim-style left |
| `j` | Down Arrow | Vim-style down |
| `k` | Up Arrow | Vim-style up |
| `l` | Right Arrow | Vim-style right |
| `y` | Home | Beginning of line |
| `u` | Page Down | Scroll down |
| `i` | Page Up | Scroll up |
| `o` | End | End of line |

### Optional Features (Commented Out)

#### Home Row Modifiers

Provides ergonomic access to modifiers without leaving home position:

| Key | Tap | Hold |
| --- | --- | --- |
| `a` | a | Left Meta (Windows key) |
| `s` | s | Left Alt |
| `d` | d | Left Shift |
| `f` | f | Left Control |
| `j` | j | Right Control |
| `k` | k | Right Shift |
| `l` | l | Right Alt |
| `;` | ; | Right Meta |

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

## Resources

- [KMonad Documentation](https://github.com/kmonad/kmonad)
- [KMonad Tutorial](https://github.com/kmonad/kmonad/blob/master/keymap/tutorial.kbd)
- [Carabiner (macOS inspiration)](https://github.com/tekezo/Karabiner-Elements)

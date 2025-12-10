# Kanata Configuration

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

### Linux (NixOS)

#### 1. Add Kanata to NixOS

Add to your `configuration.nix` or appropriate module:

```nix
# Enable Kanata
services.kanata = {
  enable = true;
  keyboards = {
    laptop = {
      device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
      config = builtins.readFile ./kanata/laptop.kbd;
    };
  };
};

# Add your user to the input and uinput groups
users.users.mario = {
  extraGroups = [ "input" "uinput" ];
};
```

#### 2. Enable uinput module

```nix
boot.kernelModules = [ "uinput" ];
```

#### 3. Rebuild NixOS

```bash
sudo nixos-rebuild switch
```

### macOS (nix-darwin)

Kanata runs as a LaunchDaemon via nix-darwin with Karabiner-DriverKit-VirtualHIDDevice.

#### 1. First-time setup

1. Activate Karabiner driver:

   ```bash
   MANAGER="/Applications/Nix Apps/.Karabiner-VirtualHIDDevice-Manager.app"
   sudo "$MANAGER/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" activate
   ```

2. Approve system extension:

   ```bash
   open "x-apple.systempreferences:com.apple.LoginItems-Settings.extension"
   ```

   Enable the Karabiner extension when prompted.

3. Add kanata to Accessibility:

   ```bash
   open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
   ```

   Click `+`, press `Shift+Cmd+G`, enter `/run/current-system/sw/bin`, select `kanata`.

4. Add kanata to Input Monitoring:

   ```bash
   open "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent"
   ```

   Same steps as Accessibility.

#### 2. Rebuild nix-darwin

```bash
just darwin
```

This creates three LaunchDaemons:

| Service                          | Purpose                       |
| -------------------------------- | ----------------------------- |
| `org.pqrs.karabiner-vhiddaemon`  | Virtual HID device (must run) |
| `org.pqrs.karabiner-vhidmanager` | Driver activation (one-shot)  |
| `org.nixos.kanata`               | Keyboard remapping            |

#### 3. Verify services

```bash
sudo launchctl list | grep -E 'kanata|karabiner'
tail /tmp/kanata.out.log
```

#### 4. Logs and troubleshooting

```bash
# Check all logs
tail /tmp/kanata.*.log /tmp/karabiner-*.log

# Emergency exit (physical keys): lctl+spc+esc
```

**Note**: The vhidmanager may show exit code 1 - this is normal if the extension was already activated.

### Windows

#### 1. Install Interception driver

Download and install from: <https://github.com/oblitum/Interception>

**Important**: Restart your computer after installation.

#### 2. Install Kanata

Download the latest Windows release from:
<https://github.com/kanata/kanata/releases>

Extract `kanata.exe` to a location in your PATH (e.g., `C:\Program Files\kanata\`).

#### 3. Test the configuration

```powershell
# Run as Administrator
kanata.exe $env:USERPROFILE\.config\kanata\windows.kbd
```

#### 4. Run on startup (optional)

Create a scheduled task to run Kanata at startup:

1. Open Task Scheduler
2. Create Basic Task
3. Trigger: At log on
4. Action: Start a program
5. Program: `C:\Program Files\kanata\kanata.exe`
6. Arguments: `%USERPROFILE%\.config\kanata\windows.kbd`
7. Check "Run with highest privileges"

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

### Kanata service fails to start

1. Check device permissions:

   ```bash
   ls -la /dev/input/by-path/platform-i8042-serio-0-event-kbd
   ```

2. Verify you're in the `input` and `uinput` groups:

   ```bash
   groups
   ```

3. Check Kanata service logs:

   ```bash
   journalctl -u kanata-laptop -f
   ```

### Keys not working as expected

1. Test configuration:

   ```bash
   sudo kanata ~/.config/kanata/laptop.kbd
   ```

2. Check for syntax errors in the `.kbd` file

## Related Documentation

- [KEYBINDINGS.md](KEYBINDINGS.md) - Complete keybinding reference
- [CLAUDE.md](CLAUDE.md) - AI guidance for Kanata configuration
- [Kanata Documentation](https://github.com/kanata/kanata) - Official documentation
- [Kanata Tutorial](https://github.com/kanata/kanata/blob/master/keymap/tutorial.kbd) - Tutorial config
- [Karabiner Elements](https://github.com/tekezo/Karabiner-Elements) - macOS inspiration

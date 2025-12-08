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

### macOS

#### 1. Install Kanata via nix-darwin

Kanata is included in the darwin packages. Rebuild your system:

```bash
just darwin
```

#### 2. Install the driverkit extension

Kanata requires the Karabiner DriverKit VirtualHIDDevice:

```bash
# Download and install Karabiner-Elements
# This also installs the required DriverKit extension
brew install --cask karabiner-elements

# Approve the extension in System Settings > Privacy & Security
# Then uninstall Karabiner-Elements if you only need the driver
# brew uninstall --cask karabiner-elements
```

Or install just the driver:

```bash
# Clone Karabiner-DriverKit-VirtualHIDDevice
git clone https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice.git
cd Karabiner-DriverKit-VirtualHIDDevice

# Build and install
make install

# Approve in System Settings > Privacy & Security
```

#### 3. Find your keyboard device name

```bash
ioreg -c IOHIDKeyboard -r | grep -i "Product"
```

Update the `iokit-name` in `~/.config/kanata/darwin.kbd` if needed.

#### 4. Run Kanata

```bash
# Test the configuration
sudo kanata ~/.config/kanata/darwin.kbd

# To run on startup, create a LaunchAgent (optional)
# See: https://github.com/kanata/kanata/blob/master/doc/installation.md#macos
```

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

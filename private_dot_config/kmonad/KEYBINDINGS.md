# KMonad Keybindings

Advanced keyboard remapping with Carabiner-style keymaps and Space Cadet keyboard emulation for ThinkPad T470.

## Primary Remappings

| Physical Key | Mapped To | Description |
| ------------ | --------- | ----------- |
| Caps Lock | Control/Escape | Tap for Escape, hold for Control |
| Tab | Tab/Hyper | Tap for Tab, hold for Hyper (Ctrl+Meta+Alt) |
| Left Ctrl | {/Ctrl | Tap for {, hold for Control |
| Right Ctrl | }/Ctrl | Tap for }, hold for Control |
| Left Shift | (/Shift | Tap for (, hold for Shift |
| Right Shift | )/Shift | Tap for ), hold for Shift |
| Left Alt | </Alt | Tap for <, hold for Alt (preserves international input) |
| Right Alt | >/Navigation | Tap for >, hold for Navigation layer |

## Navigation Layer (Hold Right Alt)

| Key | Action | Description |
| --- | ------ | ----------- |
| `h` | Left Arrow | Vim-style left |
| `j` | Down Arrow | Vim-style down |
| `k` | Up Arrow | Vim-style up |
| `l` | Right Arrow | Vim-style right |
| `y` | Home | Beginning of line |
| `u` | Page Down | Scroll down |
| `i` | Page Up | Scroll up |
| `o` | End | End of line |

## Optional Features (Commented Out)

### Home Row Modifiers

Provides ergonomic access to modifiers without leaving home position:

| Key | Tap | Hold |
| --- | --- | ---- |
| `a` | a | Left Meta (Windows key) |
| `s` | s | Left Alt |
| `d` | d | Left Shift |
| `f` | f | Left Control |
| `j` | j | Right Control |
| `k` | k | Right Shift |
| `l` | l | Right Alt |
| `;` | ; | Right Meta |

**Note**: Home row modifiers are currently disabled in the configuration but can be enabled by uncommenting the
relevant sections in `laptop.kbd`.

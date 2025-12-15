# Kanata Keybindings

Space Cadet keys + Layer-based navigation, accents, and window management.

## Primary Remappings

| Physical Key | Tap | Hold | Description |
| ------------ | --- | ---- | ----------- |
| Caps Lock | Esc | Ctrl | Escape or Control |
| Tab | Tab | Hyper | All 4 modifiers (app launchers) |
| `=` | `=` | Window | Ctrl+Cmd layer (WM control) |
| Left Shift | `(` | Shift | Parenthesis or Shift |
| Right Shift | `)` | Shift | Parenthesis or Shift |
| Left Ctrl | `{` | Ctrl | Brace or Control |
| Space | Space | Nav | Navigation layer (arrows) |
| Grave (`) | `` ` `` | Accent | Accented characters |

## Navigation Layer (Hold Space)

| Key | Action |
| --- | ------ |
| `h` | ← Left Arrow |
| `j` | ↓ Down Arrow |
| `k` | ↑ Up Arrow |
| `l` | → Right Arrow |
| `y` | Home |
| `u` | Page Down |
| `i` | Page Up |
| `o` | End |

## Window Layer (Hold `=`)

Sends Ctrl+Cmd (macOS) / Ctrl+Super (Linux) for window management.

| Key | Action | With Shift |
| --- | ------ | ---------- |
| `hjkl` | Focus/workspace | Move window |
| `1-9` | Workspace | Move to workspace |
| `f` | Fullscreen | - |
| `q` | Close | - |
| `r` | Resize mode | - |
| `Return` | Terminal | - |

## Accent Layer (Hold Grave)

| Key | Output | Key | Output |
| --- | ------ | --- | ------ |
| `a` | á | `1` | ¡ |
| `e` | é | `2` | ² |
| `i` | í | `3` | ³ |
| `o` | ó | `9` | ø |
| `u` | ú | `0` | å |
| `n` | ñ | `;` | æ |
| `s` | ß | `'` | ü |
| `c` | ç | `q` | ¿ |
| `w` | œ | `m` | µ |

## Platform-Specific Notes

| Platform | Config File | Notes |
| -------- | ----------- | ----- |
| macOS | `darwin.kbd` | Both `grv` and `nubs` mapped for multi-keyboard support |
| Linux | `laptop.kbd` | Uses `linux-dev` for device path |
| Windows | `windows.kbd` | No device path needed |

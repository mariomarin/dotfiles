# Kanata Keybindings

Space Cadet keys + Layer-based navigation and accents.

## Primary Remappings

| Physical Key | Tap | Hold | Description |
| ------------ | --- | ---- | ----------- |
| ⇪ Caps Lock | ⎋ | ⎈ | Escape or Control |
| ⭾ Tab | ⭾ | Hyper | ⎈⌥⌘⇧ (app launchers) |
| ‹⇧ Left Shift | `(` | ⇧ | Parenthesis or Shift |
| ⇧› Right Shift | `)` | ⇧ | Parenthesis or Shift |
| ‹⎈ Left Ctrl | `{` | ⎈ | Brace or Control |
| ␣ Space | ␣ | Nav | Navigation layer (arrows) |
| ˋ Grave | ˋ | Accent | Accented characters |

## Navigation Layer (Hold ␣)

| Key | Action |
| --- | ------ |
| `h` | ◀ Left |
| `j` | ▼ Down |
| `k` | ▲ Up |
| `l` | ▶ Right |
| `y` | ⇤ Home |
| `u` | ⇟ Page Down |
| `i` | ⇞ Page Up |
| `o` | ⇥ End |

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

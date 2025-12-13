# Kanata Keybindings

Space Cadet keys + Layer-based navigation and accents for US ANSI keyboards.

The accent layer provides international characters without switching keyboard layouts or using dead keys.

## Primary Remappings

| Physical Key | Tap | Hold | Description |
| ------------ | --- | ---- | ----------- |
| Caps Lock | Esc | Ctrl | Escape or Control |
| Tab | Tab | Hyper | Tab or Ctrl+Meta+Alt |
| Left Shift | `(` | Shift | Parenthesis or Shift |
| Right Shift | `)` | Shift | Parenthesis or Shift |
| Left Ctrl | `{` | Ctrl | Brace or Control |
| Space | Space | Nav Layer | Navigation layer |
| Grave (`) | `` ` `` | Accent Layer | Accented characters |

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

# Zsh VI Mode Configuration

This configuration uses [zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode) for enhanced vi mode in Zsh.

## Key Features

### Mode Switching

- `ESC`, `Ctrl+[`, or `jk` - Switch from INSERT to NORMAL mode
- `i` - Enter INSERT mode
- `v` - Enter VISUAL mode
- `V` - Enter VISUAL LINE mode
- `Ctrl+v` - Enter VISUAL BLOCK mode

The mode is indicated in the prompt/cursor:

- INSERT mode: Blinking beam cursor
- NORMAL mode: Block cursor
- VISUAL mode: Block cursor with highlighted selection

### Surround Feature

The surround feature is enabled in **classic mode** (verb->s->surround).

#### In NORMAL mode

- `cs"'` - Change surrounding " to '
- `ds"` - Delete surrounding "
- `ys$"` - Add " around text from cursor to end of line
- `ysiw'` - Add ' around inner word

#### In VISUAL mode

- `S"` - Surround selection with "
- `S'` - Surround selection with '
- `S(` or `S)` - Surround with parentheses
- `S[` or `S]` - Surround with brackets
- `S{` or `S}` - Surround with braces

### Text Objects

- `ci"` - Change inside quotes
- `di(` - Delete inside parentheses
- `vi{` - Visual select inside braces

### History Navigation

- `Ctrl+p` / `Ctrl+P` - Previous command in history (substring search)
- `Ctrl+n` / `Ctrl+N` - Next command in history (substring search)
- `/` - Search backward in history (in NORMAL mode)
- `?` - Search forward in history (in NORMAL mode)
- `n` - Repeat the last search in same direction
- `N` - Repeat the last search in opposite direction

### Command Line Editing

- `Ctrl+y` - Accept autosuggestion
- Standard vi motions work in NORMAL mode (w, b, 0, $, etc.)

## Configuration

Settings are defined in:

- `~/.config/zsh/.zshenv` - Environment variables
- `~/.config/zsh/zsh-vi-mode-config.zsh` - Post-init configuration

### Environment Variables

- `ZVM_INIT_MODE=sourcing` - Initialize in sourcing mode for better compatibility
- `ZVM_VI_INSERT_ESCAPE_BINDKEY=jk` - Use 'jk' to escape to NORMAL mode
- `ZVM_VI_SURROUND_BINDKEY=classic` - Use classic surround bindings
- `ZVM_VI_HIGHLIGHT_FOREGROUND=black` - Highlight color for surround objects
- `ZVM_VI_HIGHLIGHT_BACKGROUND=yellow` - Background color for surround objects
- `ZVM_CLIPBOARD_PROVIDER='xsel'` - Use xsel for system clipboard integration

### Clipboard Integration

With xsel clipboard provider:

- Yanking (`y`) copies to system clipboard
- Deleting (`d`, `c`) in NORMAL mode also copies to clipboard
- Pasting (`p`, `P`) uses system clipboard
- Visual mode selections can be copied with `y`
- Use `"+y` or `"*y` to explicitly yank to system clipboard registers

## Troubleshooting

### Surround not working

1. Check that the plugin is loaded: `echo $ZVM_VERSION`
2. Verify surround is enabled: `echo $ZVM_VI_SURROUND_BINDKEY`
3. Make sure you're in NORMAL or VISUAL mode when using surround commands

### Key bindings overridden

The `zvm_after_init` function in `zsh-vi-mode-config.zsh` restores custom bindings that may be overridden by the plugin.

### Performance issues

If startup is slow, ensure zsh-vi-mode is loaded after syntax highlighting as specified in zimrc.

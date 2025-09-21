# Tmux Configuration

Custom tmux configuration with vi-mode, session management, seamless navigation, and native clipboard integration.

## Requirements

### Clipboard Support

Native clipboard integration requires:

- **X11**: `xclip` package
- **Wayland**: `wl-clipboard` package (provides `wl-copy`)

The configuration automatically detects your display server (X11/Wayland) and uses the appropriate clipboard tool.

## Keybindings

**Prefix key**: `C-a` (Ctrl+a)

### Session Management

| Keybinding | Description |
| --- | --- |
| `prefix C-c` | Create new session |
| `prefix C-f` | Find and switch to session |
| `prefix T` | **Session picker (sesh)** - Interactive session management with preview |
| `prefix L` | Switch to last session (via sesh) |

#### Sesh Session Picker (`prefix T`)

Enhanced session picker with icons and preview pane showing session contents.

| Keybinding | Description |
| --- | --- |
| `Tab`/`Shift+Tab` | Navigate up/down |
| `C-a` | Show all sessions with icons |
| `C-t` | Show tmux sessions only |
| `C-g` | Show config directories |
| `C-x` | Show zoxide directories |
| `C-f` | Find directories |
| `C-d` | Kill selected session |

**Zsh Integration**: Press `Alt+s` in terminal to quickly connect to sessions

### Window Management

| Keybinding | Description |
| --- | --- |
| `M-Tab` | Switch to last active window |
| `prefix w` | Window tree picker |
| `prefix x` | Kill current pane (no confirmation) |

### Pane Management

| Keybinding | Description |
| --- | --- |
| `M-h/j/k/l` | Navigate between panes (unified for both tmux and Neovim) |
| `M-Arrow` | Resize panes by 1 step (with vim awareness) |
| `prefix C-g` | Split window and run navi |

### Clipboard Operations

| Keybinding | Description |
| --- | --- |
| `prefix y` | Copy current command line to clipboard |
| `prefix Y` | Copy current pane's working directory to clipboard |

### Copy Mode

| Keybinding | Description |
| --- | --- |
| `prefix /` | Enter copy mode and search forward |

#### Copy Mode Vi Bindings

| Keybinding | Description |
| --- | --- |
| `v` | Begin selection |
| `V` | Select line |
| `y` | Copy selection to clipboard |
| `Y` | Copy current line |
| `Enter` | Copy selection to clipboard and exit |
| `MouseDragEnd1Pane` | Copy mouse selection to clipboard |
| `C-v` | Rectangle selection toggle |
| `o` | Jump to other end of selection |
| `C-c` | Clear selection |
| `H` | Jump to start of line |
| `L` | Jump to end of line |
| `%` | Next matching bracket |
| `Escape` | Exit copy mode |

### Text Selection (tmux-fingers)

| Keybinding | Description |
| --- | --- |
| `M-f` | Start tmux-fingers (highlight text to copy) |
| `M-j` | Start tmux-fingers in jump mode |

### Plugin-Specific

#### tmux-resurrect

| Keybinding | Description |
| --- | --- |
| `prefix C-s` | Save tmux session |
| `prefix C-r` | Restore tmux session |

#### tmux-tilish (i3wm-style)

| Keybinding | Description |
| --- | --- |
| `M-0` to `M-9` | Switch to workspace 0-9 |
| `M-S-0` to `M-S-9` | Move pane to workspace 0-9 |
| `M-h/j/k/l` | Navigate panes (works everywhere now) |
| `M-S-h/j/k/l` | Move pane in direction |
| `M-Enter` | Create new pane |
| `M-s` | Layout: main-horizontal |
| `M-S-s` | Layout: even-vertical |
| `M-v` | Layout: main-vertical |
| `M-S-v` | Layout: even-horizontal |
| `M-t` | Layout: tiled |
| `M-z` | Layout: zoom (fullscreen) |
| `M-r` | Refresh current layout |
| `M-n` | Rename current window |
| `M-S-q` | Close pane |
| `M-S-e` | Detach from tmux |
| `M-S-c` | Reload tmux configuration |

#### tmux-harpoon

| Keybinding | Description |
| --- | --- |
| `C-h` | Fuzzy-jump to saved session/pane |
| `C-S-a` | Add current session to harpoon list |
| `M-a` | Add current session + pane to harpoon list |
| `C-e` | Edit harpoon saved list in popup |

#### tmux-fuzzback

| Keybinding | Description |
| --- | --- |
| `prefix ?` | Search scrollback buffer with fzf |

#### extrakto

| Keybinding | Description |
| --- | --- |
| `prefix Tab` | Launch extrakto |

##### Within extrakto mode

| Keybinding | Description |
| --- | --- |
| `Tab` | Insert selection to pane |
| `Enter` | Copy selection to clipboard |
| `C-f` | Toggle filter mode |
| `C-g` | Toggle grab mode |
| `C-e` | Edit selection in editor |
| `C-o` | Open selection with system |
| `C-h` | Show help |

### Utility

| Keybinding | Description |
| --- | --- |
| `prefix :` | Enter command prompt |
| `prefix r` | Reload tmux configuration |
| `M-S-c` | Reload tmux configuration (no prefix needed) |
| `prefix t` | Show clock |
| `prefix b` | Toggle status bar |
| `prefix B` | List paste buffers |
| `prefix p` | Paste from buffer |
| `prefix P` | Choose buffer to paste |

## Potential Conflicts ⚠️

The following keybindings have been resolved:

- **`M-h`**: tmux-tilish navigation takes precedence; tmux-harpoon uses `M-a` instead
- **`C-h`**: tmux-harpoon jump binding (no conflict with existing bindings)
- **`prefix F`**: Previously used by tmux-fzf, now available

## Plugin List

- **tmux-sensible**: Sensible tmux defaults
- **tmux-yank**: System clipboard integration
- **tmux-resurrect**: Session persistence
- **tmux-continuum**: Automatic session saves
- **tmux-fingers**: Copy text with hints (like Vimium)
- **tmux-tilish**: i3wm-like navigation
- **tmux-harpoon**: Quick navigation between saved sessions and panes
- **tmux-fuzzback**: Search scrollback with FZF
- **extrakto**: Extract and insert text

## Neovim Integration

Using **aserowy/tmux.nvim** for seamless tmux/neovim integration:

- **Navigation**: `M-h/j/k/l` to move between tmux panes and Neovim splits
  - Provided by tmux-tilish with built-in vim awareness (`is_vim` check)
  - Works seamlessly in both tmux and Neovim
- **Resizing**: Omarchy-style keybindings for pane resizing
  - `M-=` (Alt+Equal): Grow pane to the left
  - `M--` (Alt+Minus): Grow pane to the right
  - `M-+` (Alt+Shift+Equal): Grow pane down
  - `M-_` (Alt+Shift+Minus): Grow pane up
  - Provided by tmux-tilish smart splits with custom configuration
  - Works in both tmux and Neovim with vim awareness
- **Clipboard Sync**: Automatic synchronization of registers between Neovim instances and tmux
- **Cycle Navigation**: Wraps around to opposite pane when at edge

## Settings

- Mouse support enabled
- Base index starts at 1
- Vi-mode for copy mode
- True color support
- Status bar theme: minimal-tmux-status

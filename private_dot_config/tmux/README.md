# Tmux Configuration

Custom tmux configuration with vi-mode, session management, and seamless navigation.

## Keybindings

**Prefix key**: `C-a` (Ctrl+a)

### Session Management

| Keybinding | Description |
| --- | --- |
| `prefix C-c` | Create new session |
| `prefix C-f` | Find and switch to session |
| `prefix T` | **Session picker (sesh)** - Interactive session management |
| `prefix L` | Switch to last session |

#### Sesh Session Picker (`prefix T`)
| Keybinding | Description |
| --- | --- |
| `Tab`/`Shift+Tab` | Navigate up/down |
| `C-a` | Show all sessions |
| `C-t` | Show tmux sessions only |
| `C-g` | Show config directories |
| `C-x` | Show zoxide directories |
| `C-f` | Find directories |
| `C-d` | Kill selected session |

### Window Management

| Keybinding | Description |
| --- | --- |
| `M-Tab` | Switch to last active window |
| `prefix w` | Window tree picker |
| `prefix x` | Kill current pane (no confirmation) |

### Pane Management

| Keybinding | Description |
| --- | --- |
| `M-h/j/k/l` | Navigate between panes (via tmux-navigate) |
| `prefix C-g` | Split window and run navi |

### Copy Mode

| Keybinding | Description |
| --- | --- |
| `prefix /` | Enter copy mode and search forward |

#### Copy Mode Vi Bindings
| Keybinding | Description |
| --- | --- |
| `v` | Begin selection (tmux-yank) |
| `y` | Copy selection to clipboard (tmux-yank) |
| `Y` | Copy line to clipboard (tmux-yank) |
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

#### tmux-fzf
| Keybinding | Description |
| --- | --- |
| `prefix F` | Launch tmux-fzf menu |

#### tmux-fuzzback
| Keybinding | Description |
| --- | --- |
| `prefix ?` | Search scrollback buffer with fzf |

#### extrakto
| Keybinding | Description |
| --- | --- |
| `prefix Tab` | Extract text from pane |

### Utility

| Keybinding | Description |
| --- | --- |
| `prefix :` | Enter command prompt |
| `prefix t` | Show clock |
| `prefix b` | Toggle status bar |
| `prefix B` | List paste buffers |
| `prefix p` | Paste from buffer |
| `prefix P` | Choose buffer to paste |

## Duplicate Keybindings ⚠️

The following keybindings have duplicate definitions (harmless):

- **`prefix x`**: Defined twice for `kill-pane`
- **`M-f` and `M-j`**: Defined twice in tmux-fingers configuration

## Plugin List

- **tmux-sensible**: Sensible tmux defaults
- **tmux-yank**: System clipboard integration
- **tmux-resurrect**: Session persistence
- **tmux-continuum**: Automatic session saves
- **tmux-fingers**: Copy text with hints (like Vimium)
- **tmux-tilish**: i3wm-like navigation
- **tmux-navigate**: Seamless tmux/vim navigation
- **tmux-fzf**: FZF integration for tmux
- **tmux-fuzzback**: Search scrollback with FZF
- **extrakto**: Extract and insert text

## Settings

- Mouse support enabled
- Base index starts at 1
- Vi-mode for copy mode
- True color support
- Status bar theme: minimal-tmux-status
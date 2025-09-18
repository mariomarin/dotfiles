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
| `M-h/j/k/l` | Navigate between panes (unified for both tmux and Neovim) |
| `C-Arrow` | Resize panes (when in Neovim) |
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

#### tmux-yank (Copy Mode)
| Keybinding | Description |
| --- | --- |
| `y` | Copy selection to system clipboard |
| `Y` | Copy line to system clipboard |
| `C-y` | Copy selection and paste to command line |
| `M-y` | Copy selection and paste to command line (open mode) |

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
| `M-S-c` | Reload tmux config |

#### tmux-fzf
| Keybinding | Description |
| --- | --- |
| `prefix F` | Launch tmux-fzf menu ⚠️ |

#### tmux-fuzzback
| Keybinding | Description |
| --- | --- |
| `prefix ?` | Search scrollback buffer with fzf |

#### extrakto
| Keybinding | Description |
| --- | --- |
| `prefix Tab` | Launch extrakto |

##### Within extrakto mode:
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
| `prefix t` | Show clock |
| `prefix b` | Toggle status bar |
| `prefix B` | List paste buffers |
| `prefix p` | Paste from buffer |
| `prefix P` | Choose buffer to paste |

## Potential Conflicts ⚠️

The following keybindings may have conflicts:

- **`prefix F`**: Would conflict between tmux-fzf and tmux-fingers if using defaults (avoided by using custom `M-f` for tmux-fingers)

## Plugin List

- **tmux-sensible**: Sensible tmux defaults
- **tmux-yank**: System clipboard integration
- **tmux-resurrect**: Session persistence
- **tmux-continuum**: Automatic session saves
- **tmux-fingers**: Copy text with hints (like Vimium)
- **tmux-tilish**: i3wm-like navigation
- **tmux-fzf**: FZF integration for tmux
- **tmux-fuzzback**: Search scrollback with FZF
- **extrakto**: Extract and insert text

## Neovim Integration

Using **aserowy/tmux.nvim** for seamless tmux/neovim integration:
- **Navigation**: `M-h/j/k/l` to move between tmux panes and Neovim splits (unified with tmux-tilish)
- **Resizing**: `C-Arrow` keys to resize panes when in Neovim
- **Clipboard Sync**: Automatic synchronization of registers between Neovim instances and tmux
- **Cycle Navigation**: Wraps around to opposite pane when at edge

## Settings

- Mouse support enabled
- Base index starts at 1
- Vi-mode for copy mode
- True color support
- Status bar theme: minimal-tmux-status
# Tmux Keybindings

Complete keybinding reference for the tmux configuration.

**Prefix key**: `C-a` (Ctrl+a)

## Session Management

| Keybinding | Description |
| ---------- | ----------- |
| `prefix C-c` | Create new session |
| `prefix C-f` | Find and switch to session |
| `prefix T` | **Session picker (sesh)** - Interactive session management with preview |
| `prefix L` | Switch to last session (sesh → tmux → picker fallback) |

### Sesh Session Picker (`prefix T`)

Enhanced session picker with icons and preview pane showing session contents.

| Keybinding | Description |
| ---------- | ----------- |
| `Tab`/`Shift+Tab` | Navigate up/down |
| `C-a` | Show all sessions with icons |
| `C-t` | Show tmux sessions only |
| `C-g` | Show config directories |
| `C-x` | Show zoxide directories |
| `C-f` | Find directories |
| `C-d` | Kill selected session |

**Zsh Integration**: Press `Alt+s` in terminal to quickly connect to sessions

## Window Management

| Keybinding | Prefix | Description |
| ---------- | ------ | ----------- |
| `M-Space Tab` | `prefix l` / `prefix Tab` | Switch to last active window |
| | `prefix w` | Window tree picker |
| | `prefix c` | Create new window |
| | `prefix n` | Next window |
| | `prefix p` | Previous window (note: also paste buffer) |
| | `prefix 0-9` | Switch to window 0-9 |
| | `prefix ,` | Rename current window |
| | `prefix &` | Kill window (with confirmation) |
| | `prefix x` | Kill current pane (no confirmation) |
| | `prefix ;` | Switch to last pane |
| | `prefix Space` | Next layout |

## Pane Management

| Keybinding | Prefix | Description |
| ---------- | ------ | ----------- |
| `M-Space h/j/k/l` | | Navigate between panes (works with Neovim) |
| `M-Space Arrow` | | Resize panes by 1 step (vim aware) |
| | `prefix "` | Split pane horizontally |
| | `prefix %` | Split pane vertically |
| | `prefix o` | Cycle through panes |
| | `prefix q` | Display pane numbers |
| | `prefix m` | Mark current pane |
| | `prefix M` | Clear marked pane |
| | `prefix !` | Break pane to new window |
| | `prefix C-g` | Split window and run navi |

## Clipboard & Buffers

| Prefix | Description |
| ------ | ----------- |
| `prefix y` | Copy current command line to clipboard |
| `prefix Y` | Copy current pane's working directory to clipboard |
| `prefix [` | Enter copy mode |
| `prefix ]` | Paste buffer |
| `prefix p` | Paste buffer (alternative) |
| `prefix P` | Choose buffer to paste |
| `prefix B` | List buffers |
| `prefix =` | Choose buffer interactively |
| `prefix #` | List buffers (default) |
| `prefix -` | Delete buffer |

## Copy Mode

| Keybinding | Description |
| ---------- | ----------- |
| `prefix /` | Enter copy mode and search forward |

### Copy Mode Vi Bindings

| Keybinding | Description |
| ---------- | ----------- |
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

## Text Selection (tmux-thumbs)

| Keybinding | Description |
| ---------- | ----------- |
| `prefix F` | Start tmux-thumbs (highlight text with hints) |

- **Lowercase hint**: Copy to tmux buffer, show "Copied {}"
- **Uppercase hint**: Copy to buffer + open with system opener

## Plugin-Specific Keybindings

### tmux-resurrect

| Keybinding | Description |
| ---------- | ----------- |
| `prefix C-s` | Save tmux session |
| `prefix C-r` | Restore tmux session |

### tmux-tilish (i3wm-style)

**Modal prefix**: `M-Space` (Alt+Space)

| Keybinding | Prefix | Description |
| ---------- | ------ | ----------- |
| `M-Space 1-9` | `prefix 1-9` | Switch to window 1-9 |
| `M-Space 0` | `prefix 0` | Switch to window 0/10 |
| `M-Space Tab` | `prefix l` | Last active window |
| `M-Space hjkl` | | Navigate panes (vim aware) |
| `M-Space S-hjkl` | | Move pane in direction |
| `M-Space Enter` | | Create new pane |
| `M-Space S-q` | `prefix x` | Close pane |
| `M-Space z` | | Zoom (fullscreen) toggle |
| `M-Space s` | | Layout: main-horizontal |
| `M-Space S-s` | | Layout: even-vertical |
| `M-Space v` | | Layout: main-vertical |
| `M-Space S-v` | | Layout: even-horizontal |
| `M-Space t` | | Layout: tiled |
| `M-Space r` | | Refresh current layout |
| `M-Space n` | `prefix ,` | Rename current window |
| `M-Space S-e` | `prefix d` | Detach from tmux |
| `M-Space S-c` | `prefix r` | Reload configuration |
| `M-Space S-1-9` | | Move pane to window 1-9 |

### tmux-harpoon

| Keybinding | Description |
| ---------- | ----------- |
| `C-h` | Fuzzy-jump to saved session/pane |
| `C-S-a` | Add current session to harpoon list |
| `M-a` | Add current session + pane to harpoon list |
| `C-e` | Edit harpoon saved list in popup |

### tmux-fuzzback

| Keybinding | Description |
| ---------- | ----------- |
| `prefix ?` | Search scrollback buffer with fzf |

## Utility

| Prefix | Description |
| ------ | ----------- |
| `prefix :` | Enter command prompt |
| `prefix r` | Reload tmux configuration |
| `prefix R` | Reload configuration (plugin) |
| `prefix t` | Show clock |
| `prefix b` | Toggle status bar |
| `prefix i` | Display window info |
| `prefix d` | Detach client |
| `prefix D` | Choose client to detach |
| `prefix C` | Customize mode |
| `prefix f` | Find window |
| `prefix s` | Session tree picker |
| `prefix $` | Rename session |

## Neovim Integration

Using **aserowy/tmux.nvim** for seamless tmux/neovim integration:

- **Navigation**: `M-Space h/j/k/l` to move between tmux panes and Neovim splits
  - Provided by tmux-tilish with built-in vim awareness (`is_vim` check)
  - Works seamlessly in both tmux and Neovim
  - Modal prefix: `M-Space` (Alt+Space) followed by direction key
- **Resizing**: Omarchy-style keybindings for pane resizing
  - `M-Space =` (Alt+Space, then =): Grow pane to the left
  - `M-Space -` (Alt+Space, then -): Grow pane to the right
  - `M-Space +` (Alt+Space, then Shift+=): Grow pane down
  - `M-Space _` (Alt+Space, then Shift+-): Grow pane up
  - Provided by tmux-tilish smart splits with custom configuration
  - Works in both tmux and Neovim with vim awareness
- **Clipboard Sync**: Automatic synchronization of registers between Neovim instances and tmux
- **Cycle Navigation**: Wraps around to opposite pane when at edge

## Potential Conflicts ⚠️

The following keybindings have been resolved:

- **`M-Space`**: Used as modal prefix for tmux-tilish; frees up all `M-<key>` bindings for other uses
- **`M-a`**: tmux-harpoon append binding (no conflict with tilish modal prefix)
- **`C-h`**: tmux-harpoon jump binding (no conflict with existing bindings)
- **`prefix F`**: Previously used by tmux-fzf, now available

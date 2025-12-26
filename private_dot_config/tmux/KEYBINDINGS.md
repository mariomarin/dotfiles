# Tmux Keybindings

Complete keybinding reference for the tmux configuration.

**Prefix key**: `C-a` (Ctrl+a)

## Session Management

| Keybinding | Description |
| ---------- | ----------- |
| `prefix C-c` | Create new session |
| `prefix C-f` | Find and switch to session |
| `prefix T` | **Session picker (sesh)** - Interactive session management with preview |
| `prefix L` | Switch to last session (via sesh) |

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
| `M-Tab` / `C-M-Tab` | `prefix l` | Switch to last active window |
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
| `M-h/j/k/l` | | Navigate between panes (works with Neovim) |
| `M-Arrow` | | Resize panes by 1 step (vim aware) |
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

These bindings work with both `Alt+key` directly or `=+key` via kanata window mode.

| `=+key` | `Alt+key` | Prefix | Description |
| ------- | --------- | ------ | ----------- |
| `=+1-9` | `M-1-9` | `prefix 1-9` | Switch to window 1-9 |
| `=+0` | `M-0` | `prefix 0` | Switch to window 0/10 |
| `=+Tab` | `M-Tab` | `prefix l` | Last active window |
| `=+hjkl` | `M-hjkl` | | Navigate panes (vim aware) |
| `=+HJKL` | `M-S-hjkl` | | Move pane in direction |
| `=+Enter` | `M-Enter` | | Create new pane |
| `=+q` | `M-S-q` | `prefix x` | Close pane |
| `=+z` | `M-z` | | Zoom (fullscreen) toggle |
| `=+Space` | | `prefix Space` | Next layout |
| | `M-s` | | Layout: main-horizontal |
| | `M-S-s` | | Layout: even-vertical |
| | `M-v` | | Layout: main-vertical |
| | `M-S-v` | | Layout: even-horizontal |
| | `M-t` | | Layout: tiled |
| | `M-r` | | Refresh current layout |
| | `M-n` | `prefix ,` | Rename current window |
| | `M-S-e` | `prefix d` | Detach from tmux |
| | `M-S-c` | `prefix r` | Reload configuration |
| | `M-S-1-9` | | Move pane to window 1-9 |

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

### extrakto

| Keybinding | Description |
| ---------- | ----------- |
| `prefix Tab` | Launch extrakto |

#### Within extrakto mode

| Keybinding | Description |
| ---------- | ----------- |
| `Tab` | Insert selection to pane |
| `Enter` | Copy selection to clipboard |
| `C-f` | Toggle filter mode |
| `C-g` | Toggle grab mode |
| `C-e` | Edit selection in editor |
| `C-o` | Open selection with system |
| `C-h` | Show help |

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

## Potential Conflicts ⚠️

The following keybindings have been resolved:

- **`M-h`**: tmux-tilish navigation takes precedence; tmux-harpoon uses `M-a` instead
- **`C-h`**: tmux-harpoon jump binding (no conflict with existing bindings)
- **`prefix F`**: Previously used by tmux-fzf, now available

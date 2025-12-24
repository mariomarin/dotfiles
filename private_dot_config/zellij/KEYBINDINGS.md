# Zellij Keybindings

Tmux-like keybindings with `Ctrl+a` prefix. Default mode is **locked** (keys pass through).

**Prefix key**: `Ctrl+a`

## Session Management

| Keybinding | Description |
| ---------- | ----------- |
| `prefix d` | Detach from session |
| `prefix Ctrl+c` | Session manager (create/switch) |
| `prefix Ctrl+f` | Session manager (find) |
| `prefix T` | Session picker (like sesh) |
| `Ctrl+Alt+s` | Quick session manager (via Kanata `=` layer) |

## Tab Management

| Keybinding | Description |
| ---------- | ----------- |
| `prefix c` | Create new tab |
| `prefix w` | Tab picker |
| `prefix ,` | Rename current tab |
| `prefix p` / `prefix n` | Previous/next tab |
| `prefix 1-9` | Go to tab 1-9 |
| `Ctrl+Alt+1-9` | Quick tab switch (via Kanata `=` layer) |
| `Ctrl+Alt+Tab` | Toggle last tab |

## Pane Management

| Keybinding | Description |
| ---------- | ----------- |
| `prefix "` or `prefix -` | Split horizontal |
| `prefix %` or `prefix \|` | Split vertical |
| `prefix x` | Close pane |
| `prefix z` | Toggle fullscreen |
| `prefix o` | Focus next pane |
| `prefix Space` | Cycle layouts |
| `Ctrl+Alt+"` | New pane (via Kanata `=` layer) |
| `Ctrl+Alt+-` | Split down |
| `Ctrl+Alt+\` | Split right |
| `Ctrl+Alt+q` | Close pane |
| `Ctrl+Alt+z` | Toggle fullscreen |
| `Ctrl+Alt+Space` | Cycle layouts |
| `Ctrl+Alt+f` | Toggle floating panes |

## Pane Navigation

| Keybinding | Description |
| ---------- | ----------- |
| `prefix h/j/k/l` | Navigate panes |
| `prefix H/J/K/L` | Resize panes |
| `Ctrl+Alt+h/j/k/l` | Quick pane navigation (via Kanata `=` layer) |

## Copy/Scroll Mode

Enter with `prefix [` or `prefix /` (search).

| Keybinding | Description |
| ---------- | ----------- |
| `j/k` | Scroll down/up |
| `Ctrl+f/b` | Page down/up |
| `d/u` | Half page down/up |
| `g/G` | Top/bottom |
| `/` or `?` | Search |
| `n/N` | Next/previous match |
| `e` | Edit scrollback in nvim |
| `Esc` or `q` | Exit |

## Plugins

| Keybinding | Description |
| ---------- | ----------- |
| `prefix e` | File picker (strider) |
| `prefix ?` | File browser |
| `prefix b` | Toggle pane frames |
| `Ctrl+Alt+s` | Session manager (via Kanata `=` layer) |
| `Ctrl+y` | Harpoon (quick pane jump) |
| `Ctrl+o` | ZSM (zoxide session manager) |

### Harpoon (`Ctrl+y`)

Quick pane navigation like tmux-harpoon. [GitHub](https://github.com/Nacho114/harpoon)

| Key | Action |
| --- | ------ |
| `a` | Add current pane |
| `A` | Add all panes |
| `d` | Remove from list |
| `j/k` | Navigate list |
| `Enter/l` | Switch to pane |
| `Esc` | Close |

### ZSM (`Ctrl+o`)

Zoxide-integrated session manager like sesh. [GitHub](https://github.com/liam-mackie/zsm)

- Search zoxide directories
- Create sessions from directories
- Switch between sessions

## Tmux Plugin Mapping

| Tmux Plugin | Purpose | Zellij Equivalent | Status |
| ----------- | ------- | ----------------- | ------ |
| **sensible** | Sane defaults | Built-in | ✅ |
| **yank** | Clipboard integration | OSC52 + `copy_on_select` | ✅ |
| **resurrect** | Save/restore sessions | `session_serialization` | ✅ Auto |
| **continuum** | Auto-save sessions | `session_serialization` | ✅ Auto |
| **fingers** | Hint-based text copy | ❌ None | Use mouse/search |
| **tilish** | i3-style bindings | Ctrl+Alt (via Kanata) | ✅ Config |
| **harpoon** | Quick pane jump | harpoon plugin (`Ctrl+y`) | ✅ Plugin |
| **fuzzback** | Fuzzy scrollback search | Search mode (`/`) | ✅ Built-in |
| **extrakto** | Fuzzy text extraction | ❌ None | Use edit scrollback |
| **minimal-tmux-status** | Minimal status bar | Theme + compact-bar | ✅ Config |
| **sesh** | Session picker + zoxide | zsm plugin (`Ctrl+o`) | ✅ Plugin |

### Keybinding Mapping

| Tmux Binding | Action | Zellij Binding |
| ------------ | ------ | -------------- |
| `prefix C-c` | New session | `prefix Ctrl+c` |
| `prefix C-f` | Find session | `prefix Ctrl+f` |
| `prefix T` | Session picker (sesh) | `prefix T` or `Ctrl+o` |
| `prefix L` | Last session | ❌ Use session-manager |
| `M-f` | tmux-fingers | ❌ Not available |
| `M-j` | fingers jump mode | ❌ Not available |
| `M-0-9` | Switch workspace | `Ctrl+Alt+0-9` (via Kanata) |
| `M-h/j/k/l` | Navigate panes | `Ctrl+Alt+h/j/k/l` |
| `M-S-h/j/k/l` | Move pane | ❌ Not mapped |
| `M-Enter` | New pane | `Ctrl+Alt+"` |
| `M-z` | Toggle zoom | `Ctrl+Alt+z` |
| `M-n` | Rename window | `prefix ,` |
| `M-S-q` | Close pane | `Ctrl+Alt+q` |
| `M-S-e` | Detach | `prefix d` |
| `M-Tab` | Last window | `Ctrl+Alt+Tab` |
| `C-h` (harpoon) | Quick pane jump | `Ctrl+y` |
| `prefix C-s` | Save (resurrect) | Auto (no binding) |
| `prefix C-r` | Restore (resurrect) | Auto (no binding) |
| `prefix Tab` | Extrakto | ❌ Use `e` in scroll |
| `prefix ?` | Fuzzback | `prefix /` (search) |

### Missing Features

**tmux-fingers** (hint-based copy): No zellij plugin exists. Workarounds:

- Mouse selection with `copy_on_select true`
- Search mode (`prefix /`) to find and copy
- Edit scrollback (`e` in scroll mode) opens nvim

**extrakto** (fuzzy extraction): No zellij plugin exists. Workarounds:

- Search mode for finding text
- Edit scrollback for complex extraction

## Plugin Installation

External plugins require manual installation:

```bash
mkdir -p ~/.config/zellij/plugins

# Harpoon
git clone https://github.com/Nacho114/harpoon.git /tmp/harpoon
cd /tmp/harpoon
rustup target add wasm32-wasip1
cargo build --release --target wasm32-wasip1
cp target/wasm32-wasip1/release/harpoon.wasm ~/.config/zellij/plugins/

# ZSM
# Download from https://github.com/liam-mackie/zsm/releases
# or build similarly with cargo
```

# Neovim Keybindings

Complete keybinding reference for the LazyVim-based Neovim configuration.

**Leader key**: `<Space>`

## General

| Keybinding | Description |
| ---------- | ----------- |
| `;` | Enter command mode (alternative to `:`) |
| `jk` | Exit insert mode (from insert mode) |
| `<C-s>` | Save file (works in normal, insert, and visual modes) |
| `<leader>sk` | Show all keymaps (Telescope keymaps picker) |

## File Management

| Keybinding | Description |
| ---------- | ----------- |
| `<leader><space>` | Find files (Telescope) |
| `<leader>ff` | Find files (Telescope) |
| `<leader>sg` | Search with grep (Telescope) |
| `<leader>e` | Toggle file explorer (nvim-tree) |

## Buffer & Window Management

| Keybinding | Description |
| ---------- | ----------- |
| `<leader>bb` | Switch buffers |
| `<leader>wm` | Maximize/restore current window |
| `<C-w>o` | Maximize/restore current window |

## Code Editing

| Keybinding | Description |
| ---------- | ----------- |
| `<leader>ca` | Code actions (LSP) |
| `<leader>cf` | Format code |

## Navigation

### Leap.nvim (Quick Cursor Movement)

| Keybinding | Description |
| ---------- | ----------- |
| `s` | Leap forward to character |
| `S` | Leap backward to character |

### Harpoon2 (File Marks)

| Keybinding | Description |
| ---------- | ----------- |
| `<leader>H` | Add current file to Harpoon list |
| `<leader>h` | Toggle Harpoon quick menu |
| `<leader>1-9` | Jump to Harpoon mark 1-9 |

## Session Management

| Keybinding | Description |
| ---------- | ----------- |
| `<leader>qs` | Save current session |
| `<leader>ql` | Load/restore last session |
| `<leader>qd` | Don't save session on exit |
| `<leader>qq` | Quit all |

## Tmux Integration

### Pane Navigation (Works in both Neovim and tmux)

| Keybinding | Description |
| ---------- | ----------- |
| `M-h` | Navigate left |
| `M-j` | Navigate down |
| `M-k` | Navigate up |
| `M-l` | Navigate right |
| `M-\` | Go to last active pane |
| `M-Space` | Go to next pane |

### Pane Resizing (Omarchy-style)

| Keybinding | Description |
| ---------- | ----------- |
| `M-=` | Grow pane to the left (Alt+Equal) |
| `M--` | Grow pane to the right (Alt+Minus) |
| `M-+` | Grow pane down (Alt+Shift+Equal) |
| `M-_` | Grow pane up (Alt+Shift+Minus) |

## Claude Code Integration

| Keybinding | Description |
| ---------- | ----------- |
| `<leader>cc` | Toggle Claude Code (floating terminal) |
| `<leader>c.` | Continue conversation with Claude Code |
| `<leader>cr` | Reload files modified by Claude Code |

## Additional LazyVim Keybindings

LazyVim provides many more default keybindings. Some commonly used ones:

- `<leader>/` - Toggle comment
- `<leader>fn` - New file
- `<leader>fr` - Recent files
- `gcc` - Toggle line comment
- `gc` - Toggle comment (in visual mode)
- `gd` - Go to definition
- `gr` - Go to references
- `K` - Hover documentation

For a complete list of LazyVim default keybindings, see the [LazyVim keymaps documentation](https://www.lazyvim.org/keymaps).

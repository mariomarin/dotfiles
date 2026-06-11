# CLAUDE.md - Tmux Configuration

This file provides guidance to Claude Code when working with the tmux configuration.

## ⚠️ IMPORTANT: Always Update Documentation

**When making ANY changes to tmux keybindings or settings:**

1. **ALWAYS** check [docs/keybindings.md](../../../docs/keybindings.md) for conflicts first
2. **ALWAYS** update [keybindings.md](../../../docs/keybindings.md) with the change
3. **ALWAYS** update the conflict guide in docs/keybindings.md for root-level keys
4. **NEVER** leave undocumented keybindings

## Directory Structure

```text
private_dot_config/tmux/
├── CLAUDE.md           # This file - AI guidance
├── README.md           # User-facing keybindings documentation
├── tmux.conf           # Main tmux configuration
├── settings.tmux       # General tmux settings
├── plugins.tmux        # Plugin configurations
└── mappings/           # Key binding configurations
    ├── root.tmux       # Root key table mappings
    ├── prefix.tmux     # Prefix key mappings
    └── copy-mode-vi.tmux # Vi copy mode bindings
```

## Key Configuration Files

### tmux.conf

- Entry point that sources all other configuration files
- Order matters: settings → mappings → plugins → TPM initialization

### settings.tmux

- Prefix key: `C-a`
- Terminal settings (colors, mouse, etc.)
- Basic options

### plugins.tmux

- Plugin declarations and settings
- Custom keybindings for plugins
- Plugin-specific configuration
- **Note**: tmux-tilish configured with modal prefix `M-Space`
  - All tilish commands require `M-Space` first (e.g., `M-Space h` not `M-h`)
  - Frees up all `M-<key>` bindings for other plugins and tools
  - Follows i3wm-style modal pattern
- **Note**: tmux-harpoon replaced tmux-fzf for session navigation
  - Custom bindings: `M-a` and `C-S-a` (no conflicts with modal tilish)

### mappings/

- **root.tmux**: Direct keybindings without prefix
- **prefix.tmux**: Bindings requiring prefix key
- **copy-mode-vi.tmux**: Vi-style copy mode bindings

## Plugin Management

Plugins are managed declaratively through chezmoi:

- Defined in `private_dot_local/share/tmux/plugins/.chezmoiexternal.toml`
- Automatically downloaded/updated with `chezmoi apply`
- No manual TPM commands needed

## Neovim Integration

Currently using **aserowy/tmux.nvim** for seamless integration:

### Session Restoration

- Neovim uses LazyVim's persistence.nvim (not vim-obsession)
- tmux-resurrect configured to restore nvim without special session commands
- Sessions are saved automatically by persistence.nvim

### Modal Navigation & Resizing

- Navigation: `M-Space h/j/k/l` between tmux panes and Neovim splits (unified with tmux-tilish)
  - Modal prefix: `M-Space` (Alt+Space) followed by direction key
  - Works seamlessly in both tmux and Neovim with vim awareness
- Resizing: Omarchy-style keybindings (tmux-tilish smart splits + tmux.nvim)
  - `M-Space =` (Alt+Space, then =): Grow pane to the left
  - `M-Space -` (Alt+Space, then -): Grow pane to the right
  - `M-Space +` (Alt+Space, then Shift+=): Grow pane down
  - `M-Space _` (Alt+Space, then Shift+-): Grow pane up
- Clipboard sync between Neovim instances
- Configured in Neovim's `lua/plugins/tmux-navigation.lua`
- tmux-tilish configured with modal prefix in `plugins.tmux`

## Common Tasks

### Adding a New Keybinding

1. Add binding to appropriate file in `mappings/`
2. Check [docs/keybindings.md](../../../docs/keybindings.md) for conflicts
3. Update conflict guide in docs/keybindings.md for root-level keys
4. Test the binding

### Adding a New Plugin

1. Add to `.chezmoiexternal.toml` in plugins directory
2. Add configuration to `plugins.tmux`
3. Update [docs/keybindings.md](../../../docs/keybindings.md) with plugin keybindings
4. Run `chezmoi apply` to fetch plugin

### Changing Existing Bindings

1. Make the change in the appropriate file
2. Update [docs/keybindings.md](../../../docs/keybindings.md) immediately
3. Check for conflicts or duplicates

## Testing Checklist

Before committing tmux changes:

- [ ] Checked docs/keybindings.md for conflicts
- [ ] Updated docs/keybindings.md with changes
- [ ] No undocumented plugin bindings
- [ ] Tested all modified bindings

## Common Keybinding Conflicts

Watch out for these common conflicts:

- `prefix ?` - Often used by search and help features
- `prefix F` - Common for "find" features
- `M-h/j/k/l` - Navigation keys used by multiple plugins
- `prefix b` - Buffer operations vs status bar toggle

## Clipboard and Open Integration

### Architecture

Clipboard and URL opening use standalone scripts in `~/.local/bin/` that move
platform/SSH detection out of tmux config into helper scripts, reducing
config-time branching. OSC52 (`set-buffer -w`) is the truly client-aware
clipboard path. `clip`/`open` remain server-environment scoped via `$SSH_TTY`.

| Script | Purpose | SSH (linux-apt→Mac) | Local Mac | Local Linux | WSL |
| ------ | ------- | ------------------- | --------- | ----------- | --- |
| `clip` | Copy to clipboard | nc → clipper:8377 | pbcopy | xclip/wl-copy | clip.exe |
| `peek` | Open URL/file | nc → xdg-open-svc:2226 | /usr/bin/open | xdg-open | wslview |

### How it works

- **tmux-thumbs** calls `clip` and `open` directly (no platform branching in tmux config)
- **OSC52** (`set -s set-clipboard external`) handles tmux buffer → client terminal clipboard
- **SSH tunnels** (RemoteForward 8377, 2226) bridge remote → local Mac services
- **clipper** daemon on Mac accepts clipboard content on port 8377
- **xdg-open-svc** daemon on Mac opens URLs/files on port 2226

### Scope model

- **Config time** (server start): terminal features, OSC52 settings
- **Invocation time** (key press): `clip`/`open` scripts check `$SSH_TTY`
- **Client time** (attach): OSC52 (`set-buffer -w`) routes to attached terminal

### Limitation: `$SSH_TTY` reflects server start context

The `clip`/`open` scripts check `$SSH_TTY` to decide SSH vs local. This reflects
the environment where the **tmux server was started**, not the currently attached
client. This is correct for our setup because:

- linux-apt: tmux always starts via SSH (`RemoteCommand zsh -l`)
- macOS/NixOS: tmux always starts locally

If tmux were started by systemd and later attached over SSH, `clip`/`open` would
incorrectly use the local path. OSC52 (`set-buffer -w`) handles this correctly
since it routes to the actual attached terminal.

### Thumbs interpolation

`{}` is interpolated by tmux-thumbs before shell execution. Double-quoting
(`"{}"`) handles spaces and `&` but is NOT fully safe for all shell metacharacters
(embedded quotes, `$(...)`, backticks). This is a known tmux-thumbs limitation.

`clip` is best-effort (`;` not `&&`) so OSC52 clipboard works even if clip fails.
`peek` does NOT write to clipboard (`set-buffer` without `-w`).

### Platform detection: helper scripts on PATH

Helper scripts (`clip`, `peek`) in `~/.local/bin/` centralize platform/SSH
detection. They are called by name (not absolute path) in tmux config —
`~/.local/bin` must be on PATH in the tmux server environment (set in
`default-shell` or shell profile).

The scripts are server-environment scoped (check `$SSH_TTY` at invocation, which
reflects tmux server start context). This is correct only when tmux always starts
in the same context it runs in. OSC52 (`set-buffer -w`) is the truly client-aware
clipboard path.

```tmux
set -g @thumbs-command 'tmux set-buffer -w -- "{}"; echo -n "{}" | clip 2>/dev/null; ...'
set -g @thumbs-upcase-command 'tmux set-buffer -- "{}"; peek "{}"; ...'
```

## Troubleshooting

### tmux-thumbs fails to build on macOS (Nix-managed Rust)

TPM runs `cargo build --release` inside `~/.local/share/tmux/plugins/tmux-thumbs/`.
With Nix-provided Rust, the linker fails with `library not found for -liconv`.

Fix — build manually with rustup toolchain and SDK library path:

```bash
cd ~/.local/share/tmux/plugins/tmux-thumbs
LIBRARY_PATH="/Library/Developer/CommandLineTools/SDKs/MacOSX15.4.sdk/usr/lib" \
PATH="/Users/mario/.rustup/toolchains/stable-aarch64-apple-darwin/bin:$PATH" \
cargo build --release
```

The binaries land in `target/release/` which is where the plugin scripts expect them.

## Important Notes

- Always preserve user preferences when resolving conflicts
- Document WHY a conflict was resolved in a particular way
- Keep docs/keybindings.md as the single source of truth for keybindings
- Test integration with Neovim after navigation changes

# CLAUDE.md - Hammerspoon Configuration

macOS workspace management via Kanata's window layer (`=` hold → `Ctrl+Alt`).

## Architecture

```text
Kanata (hold =) → Ctrl+Alt+key → Hammerspoon → macOS Spaces API
```

## Keybindings

All triggered by holding `=` in Kanata (sends `Ctrl+Alt+` prefix):

| Key | Action |
| --- | ------ |
| `1-9` | Switch to desktop |
| `Shift+1-9` | Move window to desktop (follows) |
| `h` / `l` | Previous / next space (wraps) |
| `j` / `k` | Focus window below / above |
| `w` | Swap all windows between monitors |
| `Shift+,` / `Shift+.` | Move window to prev / next monitor |
| `i` | Debug: show desktop info |

## Setup Requirements

1. **Accessibility permission** for Hammerspoon
2. **9 desktops** created manually in Mission Control
3. **Install + auto-start**: `hammerspoon` cask in `nix/darwin/modules/homebrew.nix`, "Launch at login" in its preferences
4. **Config path**: `~/.config/hammerspoon/` (XDG, set via `defaults write`)

## File

- `init.lua` — single file, auto-reloads on save via `hs.pathwatcher`

## Integration Points

- **Kanata**: `darwin.kbd` window layer sends the `Ctrl+Alt` combos
- **Chezmoi**: deploys `init.lua` on macOS only (`.chezmoiignore`)

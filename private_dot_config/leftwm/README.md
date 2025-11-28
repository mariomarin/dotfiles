# LeftWM Configuration

LeftWM is a tiling window manager for X11 that focuses on simplicity and flexibility.

## Features

- **Tiling Layouts**: 14 built-in layouts including MainAndVertStack, Fibonacci, GridHorizontal, and more
- **Workspace System**: 9 workspaces with Font Awesome icons
- **Modular Design**: Separate core and theme configurations
- **Systemd Integration**: Compositor, status bar, and wallpaper rotation managed via systemd services
- **i3wm-style Keybindings**: Familiar keybindings for i3 users

## Keybindings

For a complete list of keybindings, see **[KEYBINDINGS.md](KEYBINDINGS.md)**.

**Quick reference**:

- **Mod key**: Super/Windows key (Mod4)
- **Terminal**: `Mod + Shift + Return`
- **Application menu**: `Mod + Space`
- **Close window**: `Mod + Shift + q`
- **Reload config**: `Mod + Shift + r`

## Configuration Structure

LeftWM separates configuration into two distinct parts:

### Core Configuration (`config.ron`)

Functional settings that remain consistent across themes:

- Keybindings and shortcuts
- Workspace and tag definitions
- Window rules and behaviors
- Available layouts
- Scratchpad definitions
- Focus behavior settings

### Theme Configuration (`themes/custom/`)

Visual settings that can change with themes:

- `theme.ron` - Border colors, margins, gaps
- `up` - Script to start theme components (polybar, picom, wallpaper)
- `down` - Script to clean up when switching themes

The `themes/current` symlink points to the active theme directory.

## Available Layouts

Cycle through layouts with `Mod + Ctrl + j/k`:

1. MainAndVertStack (default)
2. MainAndHorizontalStack
3. MainAndDeck
4. GridHorizontal
5. EvenHorizontal
6. EvenVertical
7. Fibonacci
8. LeftMain
9. CenterMain
10. CenterMainBalanced
11. CenterMainFluid
12. Monocle
13. RightWiderLeftStack
14. LeftWiderRightStack

## Workspace Icons

Workspaces are labeled with Font Awesome icons:

1. 󰌾 Terminal/Development
2. 󰊯 Web Browser
3. 󰈸 Code Editor
4. 󰋅 Books/Documentation
5. 󰋆 Graphics/Design
6. 󰀁 Music
7. 󰇮 Email
8. 󰈀 Notes/Writing
9. 󰊻 Gaming

## Integrated Services

### Picom (Compositor)

- X11 compositor for transparency, shadows, and effects
- Configuration: `~/.config/picom/picom.conf`
- Managed via systemd: `systemctl --user status picom`

### Polybar (Status Bar)

- Multi-monitor status bar
- Configuration: `~/.config/polybar/config.ini`
- Managed via systemd: `systemctl --user status polybar`

### Wallpaper Rotation

- Automatically rotates wallpapers from `~/.wallpaper/`
- Rotation every 30 minutes
- Managed via systemd timer: `systemctl --user status wallpaper-rotation.timer`

## Common Tasks

### Reload Configuration

- **Soft reload**: `Mod + Shift + r` (preserves windows and sessions)
- **Command line**: `leftwm-command SoftReload`

### Check Service Status

```bash
systemctl --user status picom polybar wallpaper-rotation.timer
```

### Manual Wallpaper Change

```bash
systemctl --user start wallpaper-rotation.service
```

## Troubleshooting

### Services Not Starting

1. Check if services exist: `systemctl --user list-unit-files | grep -E 'picom|polybar'`
2. Reload daemon: `systemctl --user daemon-reload`
3. Check logs: `journalctl --user -u SERVICE_NAME -f`

### Theme Not Loading

1. Verify symlink: `ls -la ~/.config/leftwm/themes/current`
2. Check theme scripts are executable
3. Run up script manually: `~/.config/leftwm/themes/current/up`

### Multi-Monitor Issues

1. Check xrandr output: `xrandr --query`
2. Verify polybar launch script: `~/.config/polybar/launch.sh`
3. Check polybar logs: `tail -f /tmp/polybar-*.log`

## Related Documentation

- [KEYBINDINGS.md](KEYBINDINGS.md) - Complete keybinding reference
- [CLAUDE.md](CLAUDE.md) - AI guidance for LeftWM configuration
- [LeftWM Wiki](https://github.com/leftwm/leftwm/wiki) - Official documentation

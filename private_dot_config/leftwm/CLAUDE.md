# CLAUDE.md - LeftWM Configuration

This directory contains LeftWM window manager configuration managed by chezmoi.

## Directory Structure

```text
private_dot_config/leftwm/
├── CLAUDE.md           # This file - AI guidance
├── config.ron.tmpl     # Main LeftWM configuration (keybindings, layouts, etc.)
└── themes/
    ├── current/        # Symlink to active theme (points to custom/)
    └── custom/         # Custom theme managed by chezmoi
        ├── up.tmpl     # Theme startup script
        ├── down.tmpl   # Theme cleanup script
        └── theme.ron.tmpl # Theme-specific settings (colors, borders)
```

## Configuration Separation

LeftWM separates configuration into two distinct parts:

### 1. Core Configuration (`~/.config/leftwm/config.ron`)

- **Functional settings** that remain consistent across themes:
  - Keybindings and shortcuts
  - Workspace and tag definitions
  - Window rules and behaviors
  - Available layouts
  - Scratchpad definitions
  - Focus behavior settings

### 2. Theme Configuration (`~/.config/leftwm/themes/[theme-name]/`)

- **Visual settings** that can change with themes:
  - `theme.ron` - Appearance settings:
    - Border width and colors
    - Window margins and gaps (margin, gutter, workspace_margin)
    - Default window sizes
  - `up` - Script to start theme components (polybar, picom, wallpaper)
  - `down` - Script to clean up when switching themes
  - Theme-specific configs (if any)

The `themes/current` symlink points to the active theme directory, allowing LeftWM to load the correct visual
settings while maintaining your core configuration.

## Configuration Philosophy

- **Systemd Integration**: Use systemd user services instead of process management in scripts
- **Modular Design**: Separate WM config from theme config
- **Desktop-Only**: Only created on machines with `desktop = true`

## Custom Theme

The `custom` theme is designed to work with systemd services:

### Theme Scripts

- **up**: Loads theme, sets wallpaper, starts services via systemd
- **down**: Unloads theme, stops services via systemd

### Managed Services

1. **picom.service** - X11 compositor for transparency/effects
2. **polybar.service** - Status bar with multi-monitor support
3. **wallpaper-rotation.timer** - Rotates wallpapers every 30 minutes

## Key Bindings (Mod4 = Super/Windows key)

### Window Management

- `Mod4 + Shift + q` - Close window
- `Mod4 + Shift + r` - Soft reload LeftWM
- `Mod4 + Enter` - Move window to top of stack
- `Mod4 + j/k` - Focus down/up
- `Mod4 + Shift + j/k` - Move window down/up

### Workspace Navigation

- `Mod4 + 1-9` - Go to workspace 1-9
- `Mod4 + Shift + 1-9` - Move window to workspace 1-9
- `Mod4 + Alt + Tab` - Jump to next workspace
- `Mod4 + Alt + Shift + Tab` - Jump to previous workspace
- `Mod4 + Ctrl + Tab` - Jump to former workspace (swap to last)
- `Mod4 + h/l` - Focus previous/next workspace
- `Mod4 + w` - Swap to last workspace

### Layouts

- `Mod4 + Control + j/k` - Previous/Next layout

### Applications

- `Mod4 + space` - Launch rofi (application launcher)
- `Mod4 + Shift + Return` - Launch alacritty terminal
- `Mod4 + y` - YouTube search (ytfzf)
- `Mod4 + p` - Power menu (shutdown/reboot/logout)
- `Mod4 + Control + l` - Lock screen (slock)
- `Mod4 + Shift + x` - Logout

### Screenshots

- `Print Screen` - Screenshot a region (select with mouse)
- `Shift + Print Screen` - Screenshot active window
- `Ctrl + Print Screen` - Screenshot full monitor
- Screenshots saved to `~/Pictures/screenshots/`

## Integration with Other Components

### Polybar

- Configuration expected at `~/.config/polybar/config.ini`
- Launched via systemd service
- Multi-monitor support via launch script

### Picom

- Configuration at `~/.config/picom/picom.conf`
- Provides transparency, shadows, blur effects
- Managed via systemd service

### Wallpapers

- Place images in `~/.wallpaper/`
- Initial wallpaper set by theme
- Rotation handled by systemd timer

## Common Tasks

### Change Theme

```bash
# Theme is set via symlink by chezmoi
# Current theme: ~/.config/leftwm/themes/current -> custom
```

### Reload Configuration

- `Mod4 + Shift + r` - Soft reload (preserves windows)
- Or: `leftwm-command SoftReload`

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

- [Root CLAUDE.md](../../CLAUDE.md) - Repository overview
- [Polybar CLAUDE.md](../polybar/CLAUDE.md) - Status bar configuration
- [LeftWM Documentation](https://github.com/leftwm/leftwm/wiki)

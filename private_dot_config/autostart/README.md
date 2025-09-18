# Autostart Applications

This directory contains desktop files for applications that should start automatically when logging into the desktop session.

## Current Applications

### CopyQ

- **Purpose**: Advanced clipboard manager
- **Delay**: 2 seconds after login
- **Why**: Provides clipboard history and advanced clipboard management features

### Firefox

- **Purpose**: Web browser
- **Delay**: 5 seconds after login
- **Why**: Quick access to web browsing after login

### LXRandR

- **Purpose**: Monitor configuration
- **Why**: Applies display settings on login

## Removed Applications

### ssh-agent.desktop

- **Removed**: This file is managed by chezmoi to be removed
- **Reason**: Conflicts with GNOME Keyring's built-in SSH agent functionality
- **Alternative**: GNOME Keyring provides SSH agent via `/run/user/$(id -u)/gcr/ssh` or `/run/user/$(id -u)/keyring/ssh`

## Notes

- GNOME Keyring automatically provides SSH agent functionality
- The zshrc configuration already detects and uses GNOME's SSH agent
- Having multiple SSH agents can cause authentication issues

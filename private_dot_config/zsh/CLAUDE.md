# CLAUDE.md - Zsh Configuration

This directory contains Zsh configuration files managed by chezmoi.

## Directory Structure

```text
private_dot_config/zsh/
├── dot_zshenv              # Environment variables (sourced first)
├── dot_zshrc               # Interactive shell configuration
├── atuin-config.zsh        # Atuin history search configuration
├── zsh-vi-mode-config.zsh  # Vi mode configuration
└── README-vi-mode.md       # User documentation for vi mode
```

## Key Components

### Environment Variables (`dot_zshenv`)

- Sets up PATH for various tools (npm, go, rust, etc.)
- Configures editor and terminal preferences
- Sets up Zim framework paths
- Configures zsh-vi-mode environment variables
- Uses GNOME Keyring for SSH agent

### Interactive Configuration (`dot_zshrc`)

- Sources atuin and zsh-vi-mode configurations
- Defines shell aliases
- Initializes Zim framework
- Configures SSH agent integration
- Sets up zoxide and direnv

### Atuin Integration (`atuin-config.zsh`)

- Sets `ATUIN_NOBIND=true` to disable default bindings
- Defines custom key bindings for vi mode compatibility
- Must be sourced before Zim modules load

### Vi Mode Configuration (`zsh-vi-mode-config.zsh`)

- Restores key bindings after zsh-vi-mode initialization
- Integrates fzf, atuin, and other tools
- Handles surround feature and clipboard integration

## Zim Framework

The configuration uses [Zim](https://zimfw.sh/) for plugin management. Key modules:

- `zsh-users/zsh-autosuggestions`
- `zsh-users/zsh-syntax-highlighting`
- `jeffreytse/zsh-vi-mode`
- `atuinsh/atuin`
- `fzf`

## SSH Agent Configuration

Managed by zim module at `~/.config/zim/modules/ssh-agent/`.

See [zim CLAUDE.md](../zim/CLAUDE.md#ssh-agent-module) for details.

## Key Bindings

### Standard Navigation

- `Ctrl+P/N` - History substring search
- `Ctrl+Y` - Accept autosuggestion
- `jk` - Exit insert mode (vi mode)

### Tool Integration

- `Ctrl+R` - Atuin history search (replaces fzf)
- `Ctrl+T` - fzf file search
- `Alt+C` - fzf directory change

## Common Tasks

### Adding a New Alias

Edit `dot_zshrc` and add to the aliases section.

### Modifying Key Bindings

Add bindings to `zvm_after_init()` function in `zsh-vi-mode-config.zsh`.

### Adding Zim Modules

Edit `~/.config/zim/zimrc` and run `zimfw install`.

## Important Notes

- Vi mode configuration must be sourced early
- Atuin config must load before Zim modules
- Key bindings in `zvm_after_init` override plugin defaults
- Use chezmoi to manage changes: `chezmoi edit ~/.config/zsh/.zshrc`

# AGENTS.md - Zsh/Zim Configuration

This file provides guidance to AI agents and assistants when working with the Zsh and Zim framework configuration.

## Directory Structure

```
private_dot_config/
├── zsh/
│   ├── dot_zshenv          # Environment variables
│   └── dot_zshrc           # Zsh configuration
└── zim/
    ├── zimrc               # Zim framework configuration
    ├── dot_latest_version.tmpl # Version tracking template
    └── modules/
        └── container-use/  # Custom completion module
            ├── init.zsh    # Module initialization
            └── functions/  # Completion functions
```

## Zim Framework

Zim is a modular Zsh framework that provides:
- Fast startup times
- Modular plugin system
- Built-in themes and completions
- Git integration
- Syntax highlighting

## Configuration Components

### Environment Variables (`dot_zshenv`)
- Sets up PATH
- Defines ZDOTDIR
- Configures development environments
- Sets default applications

### Zsh Configuration (`dot_zshrc`)
- Sources Zim framework
- Loads custom aliases
- Configures prompt
- Sets up key bindings
- Initializes tools (direnv, zoxide, etc.)

### Zim Modules (`zimrc`)
- **Core Modules**:
  - `environment` - Sets general Zsh options
  - `input` - Configures key bindings
  - `completion` - Tab completion settings
  - `git` - Git aliases and functions

- **Enhancement Modules**:
  - `zsh-syntax-highlighting` - Command syntax highlighting
  - `zsh-autosuggestions` - Fish-like autosuggestions
  - `zsh-completions` - Additional completion definitions
  - `fzf` - Fuzzy finder integration

- **Custom Modules**:
  - `container-use` - Completions for container-use tool

## Custom Completion Modules

### Creating a New Completion Module

1. Create module directory:
   ```bash
   mkdir -p private_dot_config/zim/modules/<tool-name>
   ```

2. Create `init.zsh` with completion generation:
   ```zsh
   # Generate completions if binary has changed
   if command -v <tool> >/dev/null 2>&1; then
     # Generate and cache completions
   fi
   ```

3. Add to `zimrc` BEFORE the completion module:
   ```zsh
   zmodule ${ZIM_CONFIG_FILE:h}/modules/<tool-name>
   ```

### Module Load Order
**Critical**: Custom completion modules must load BEFORE zimfw's completion module to ensure proper initialization.

## Key Features

### Aliases
Common aliases defined in the configuration:
- Git shortcuts
- Directory navigation
- File operations
- Development tools

### Key Bindings
- Vi mode with visual feedback
- Emacs-style line editing
- History search with arrow keys
- Word navigation with Ctrl+arrows

### Completions
- Command completions with descriptions
- Path expansion
- Git branch/tag completion
- Container and Kubernetes completions

## Integration Points

### Development Tools
- **direnv**: Automatic environment loading
- **zoxide**: Smart directory jumping
- **fzf**: Fuzzy file and history search
- **starship**: Cross-shell prompt (if preferred over Zim's prompt)

### Container Tools
- Docker/Podman completions
- Kubernetes (kubectl) completions
- Custom container-use completions

## Common Tasks

### Adding Aliases
1. Edit `dot_zshrc`
2. Add alias in the appropriate section
3. Source with `source ~/.zshrc` or start new shell

### Installing Zim Modules
1. Add module to `zimrc`
2. Run `zimfw install`
3. Restart shell or source configuration

### Updating Completions
1. For custom tools, update the module's init.zsh
2. Clear completion cache: `rm -rf ~/.cache/zim/completions`
3. Restart shell to regenerate

### Debugging
```bash
# Check Zim status
zimfw info

# Update Zim and modules
zimfw update

# Clean and reinstall
zimfw uninstall && zimfw install

# Check completion system
echo $fpath
compaudit
```

## Performance Optimization

### Startup Time
- Lazy load heavy functions
- Use `zimfw compile` for byte-compilation
- Minimize synchronous operations in zshrc

### Completion Cache
- Completions are cached in `~/.cache/zim/`
- Clear cache if completions are outdated
- Module init.zsh handles cache invalidation

## Important Notes

- Always test changes in a new shell before committing
- Module order in zimrc matters for dependencies
- Custom modules go in `private_dot_config/zim/modules/`
- Use templates (.tmpl) for machine-specific configurations
- Keep startup time under 100ms for best experience

## Related Documentation

- [Root AGENTS.md](../../AGENTS.md)
- [Tmux AGENTS.md](../tmux/AGENTS.md)
- [Zim Documentation](https://zimfw.sh/)
- [Zsh Manual](https://zsh.sourceforge.io/Doc/)
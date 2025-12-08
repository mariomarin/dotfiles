# Topgrade Configuration Documentation

## Overview

Topgrade is a tool that detects and upgrades all software installed on your system. This configuration is used to
customize its behavior.

## Configuration File

- **Location**: `~/.config/topgrade.toml`
- **Example**: See [topgrade-example.toml](./topgrade-example.toml) or the [official example](https://github.com/topgrade-rs/topgrade/blob/main/config.example.toml)

## Validating Configuration

### Check TOML Syntax

```bash
# Validate TOML syntax with a dry run
topgrade --dry-run

# Or use a TOML validator
cat ~/.config/topgrade.toml | python3 -m tomli
```

### Schema Validation

Unfortunately, topgrade doesn't provide a formal schema file, but it validates configuration at runtime. Invalid
fields will cause errors when running topgrade.

## Current Configuration

### Disabled Steps

- `containers` - Docker/Podman containers (managed separately)
- `firmware` - Firmware updates (handle manually for safety)
- `restarts` - Auto-restart services (avoid unexpected restarts)
- `vscode` - VSCode extensions (using Neovim instead)
- `poetry` - Poetry packages (not in use)

### Custom Commands

- **Post-commit hook**: Automatically adds lock files to chezmoi after updates
  - `~/.config/nvim/lazy-lock.json` - Neovim plugin versions
  - `~/.config/zim/.latest_version` - Zim framework version

### Platform-Specific Settings

#### Linux

- **Nix**: Uses flake mode (`--flake`)
- **Nix Env**: Prebuilt packages only (`--prebuilt-only`)
- **APT**: Only upgrade existing packages (`--only-upgrade`)
- **DNF**: Refresh metadata (`--refresh`)

#### Development Tools

- **Vim**: Don't force plugin updates
- **Python**: Enable pip-review for updates
- **Tmux**: Update plugins via TPM (path: ~/.local/share/tmux/plugins/tpm)
- **Distrobox**: Run without root

## Common Issues and Solutions

### Invalid Configuration Fields

If you see errors like "unknown field", check the
[example config](https://github.com/topgrade-rs/topgrade/blob/main/config.example.toml) for valid fields in your
topgrade version.

### Version Compatibility

Different versions of topgrade may have different configuration options:

```bash
# Check your topgrade version
topgrade --version

# View changelog for configuration changes
# https://github.com/topgrade-rs/topgrade/blob/main/CHANGELOG.md
```

### Testing Changes

Always test configuration changes with a dry run:

```bash
topgrade --dry-run
```

## Tips

1. **Incremental Changes**: Add configuration options one at a time and test
2. **Comments**: Document why certain tools are disabled
3. **Lock Files**: Use post-commands to track version lock files in your dotfiles
4. **Skip Updates**: Use `CHEZMOI_SKIP_UPDATES=1` environment variable to skip topgrade when needed

## Related Files

- `justfile` - Contains `just update` commands that use topgrade
- `.chezmoiscripts/run_after_20-topgrade-updates.sh` - Runs topgrade after chezmoi apply
- `devenv.nix` - Post-commit hook runs `just` which may trigger topgrade

## Useful Commands

```bash
# Update everything
just update

# Update only plugins
just update-plugins

# Update only system packages
just update-system

# Skip topgrade during chezmoi apply
CHEZMOI_SKIP_UPDATES=1 chezmoi apply
```

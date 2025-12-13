# Nushell Plugins

Plugins extend Nushell with additional data formats, integrations, and utilities.

## Installed Plugins

| Plugin        | NixOS/Darwin | Windows | Usage                                   |
| ------------- | ------------ | ------- | --------------------------------------- |
| **clipboard** | manual       | nupm    | `clipboard copy`, `clipboard paste`     |
| **formats**   | nixpkgs      | nupm    | Auto-loaded (EML, ICS, INI, plist, VCF) |
| **query**     | nixpkgs      | nupm    | `query web`, `query json`               |
| **gstat**     | nixpkgs      | nupm    | `gstat` (git status data)               |

## Installation Methods

### NixOS/Darwin (via Nix)

Installed via `nix/common/modules/cli-tools.nix`:

```nix
nushellPlugins.formats
nushellPlugins.query
nushellPlugins.gstat
```

Auto-registered via system PATH.

### Windows (via nupm)

Plugins declared in `~/.config/nushell/plugins.nuon`, installed by chezmoi script:

```bash
# Add plugins to plugins.nuon, then apply
chezmoi apply
```

### Manual Installation (If Needed)

```bash
# Via cargo
cargo install nu_plugin_<name>
plugin add ~/.cargo/bin/nu_plugin_<name>

# Via nupm
git clone https://github.com/<repo>/nu_plugin_<name>.git
nupm install --path nu_plugin_<name> -f
```

## Available Plugins

See [awesome-nu](https://github.com/nushell/awesome-nu/blob/main/plugin_details.md) for complete catalog.

**Notable plugins:**

- `nu_plugin_desktop_notifications` - Desktop notifications
- `nu_plugin_highlight` - Syntax highlighting
- `nu_plugin_polars` - DataFrame operations
- `nu_plugin_skim` - Fuzzy finder integration

## Verification

```nu
# List registered plugins
plugin list

# Test clipboard
"test" | clipboard copy
clipboard paste
```

## Troubleshooting

**Plugin version mismatch:**

```bash
# Reinstall after nushell update
cargo install nu_plugin_<name> --force
plugin add ~/.cargo/bin/nu_plugin_<name>
```

**Plugin not found:**

```bash
# Check installation
which nu_plugin_<name>

# Re-register with full path
plugin add $(which nu_plugin_<name>)
```

## References

- [Nushell Plugin Docs](https://www.nushell.sh/book/plugins.html)
- [awesome-nu Plugin List](https://github.com/nushell/awesome-nu)

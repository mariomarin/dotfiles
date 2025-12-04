# Nushell Plugins Installation Guide

This guide covers installing essential Nushell plugins to enhance functionality.

## Overview

Nushell plugins are external binaries that extend Nushell's capabilities. They must be:

1. Installed (via cargo or system package manager)
2. Registered with Nushell (via `plugin add`)
3. Used in scripts or commands

## Essential Plugins

### 1. nu_plugin_skim - Fuzzy Selection (fzf equivalent)

**Purpose**: Interactive fuzzy finding within Nushell pipelines

**Installation**:

```bash
# Install via cargo
cargo install nu_plugin_skim

# Register with nushell
nu -c "plugin add ~/.cargo/bin/nu_plugin_skim"
```

**Usage**:

```nu
# Select from list
ls | skim

# Select file interactively
open (ls | get name | skim)

# Select from JSON
open data.json | skim
```

### 2. nu_plugin_clipboard - Clipboard Integration

**Purpose**: Read and write system clipboard

**Installation**:

```bash
# Install via cargo
cargo install nu_plugin_clipboard

# Register with nushell
nu -c "plugin add ~/.cargo/bin/nu_plugin_clipboard"
```

**Usage**:

```nu
# Copy to clipboard
"hello world" | clipboard copy

# Paste from clipboard
clipboard paste

# Pipe clipboard to commands
clipboard paste | lines | where $it =~ 'search'
```

### 3. nu_plugin_gstat - Git Status

**Purpose**: Enhanced git status information

**Installation**:

```bash
# Install via cargo
cargo install nu_plugin_gstat

# Register with nushell
nu -c "plugin add ~/.cargo/bin/nu_plugin_gstat"
```

**Usage**:

```nu
# Get git status
gstat

# Filter git status
gstat | where status == "modified"
```

## Optional Plugins

### nu_plugin_plot - Terminal Plotting

**Purpose**: Visualize data in terminal

```bash
cargo install nu_plugin_plot
nu -c "plugin add ~/.cargo/bin/nu_plugin_plot"
```

**Usage**:

```nu
# Plot data
seq 1 100 | each { |x| {x: $x, y: ($x * $x)} } | plot
```

### nu_plugin_query - Query JSON/XML/HTML

**Purpose**: Query structured data with CSS/XPath selectors

```bash
cargo install nu_plugin_query
nu -c "plugin add ~/.cargo/bin/nu_plugin_query"
```

**Usage**:

```nu
# Query HTML
http get https://example.com | query web --query 'title'

# Query JSON with jq-like syntax
open data.json | query json '.items[] | select(.active)'
```

## Verification

After installing plugins, verify they're loaded:

```nu
# List all registered plugins
plugin list

# Test plugin functionality
"test" | clipboard copy
clipboard paste
```

## Plugin Registry

Nushell maintains a plugin registry at `~/.config/nushell/plugin.msgpackz`. This file is automatically managed by Nushell.

## Troubleshooting

### Plugin not found

```bash
# Ensure plugin binary is in PATH or specify full path
which nu_plugin_skim

# Re-register with full path
nu -c "plugin add $(which nu_plugin_skim)"
```

### Plugin version mismatch

```text
Error: Plugin protocol version mismatch
```

**Solution**: Rebuild plugins after Nushell updates

```bash
# Reinstall all plugins
cargo install nu_plugin_skim --force
cargo install nu_plugin_clipboard --force
# ... etc

# Re-register
nu -c "plugin add ~/.cargo/bin/nu_plugin_skim"
nu -c "plugin add ~/.cargo/bin/nu_plugin_clipboard"
```

### List outdated plugins

```nu
plugin list | where is_loaded == false
```

## Automated Installation

You can automate plugin installation with a script:

```nu
#!/usr/bin/env nu
# install-plugins.nu

let plugins = [
    "nu_plugin_skim"
    "nu_plugin_clipboard"
    "nu_plugin_gstat"
]

for plugin in $plugins {
    print $"Installing ($plugin)..."
    cargo install $plugin

    print $"Registering ($plugin)..."
    plugin add $"~/.cargo/bin/($plugin)"
}

print "✅ All plugins installed"
```

## Platform-Specific Notes

### Windows

Plugins use `.exe` extension:

```nu
plugin add $"($env.USERPROFILE)\\.cargo\\bin\\nu_plugin_skim.exe"
```

### macOS

No special considerations, same as Linux.

### NixOS

Plugins need to be in PATH or installed via Nix:

```nix
# In configuration.nix or home-manager
environment.systemPackages = with pkgs; [
  # Nushell plugins (if available in nixpkgs)
  # Otherwise install via cargo
];
```

## Further Reading

- [Nushell Plugin Documentation](https://www.nushell.sh/book/plugins.html)
- [Available Plugins](https://github.com/nushell/awesome-nu#plugins-60)
- [Creating Custom Plugins](https://www.nushell.sh/contributor-book/plugins.html)

# Shared Nix Modules

This directory contains Nix modules shared between NixOS (Linux) and nix-darwin (macOS).

## Philosophy

**Share what's identical, specialize what's different.**

Shared modules contain:

- CLI tools that work identically on both platforms
- Development toolchains (Go, Python, Rust, Node.js)
- Cross-platform GUI applications (browsers, editors, terminals)
- Common configurations (shell, direnv, git)

Platform-specific modules handle:

- System services (systemd vs launchd)
- Desktop environments (GNOME vs macOS Aqua)
- Platform-specific applications
- Hardware configuration

## Available Shared Modules

### `modules/cli-tools.nix`

Essential CLI utilities for daily use:

- Shells: zsh, nushell, tmux
- Editor: neovim
- Version control: git, gh, git-branchless
- Modern replacements: bat, eza, ripgrep, fd, delta, zoxide
- Development: just, direnv
- Utilities: fzf, jq, curl, htop, topgrade

**Import in NixOS**:

```nix
# nixos/hosts/*/configuration.nix
imports = [
  ../../common/modules/cli-tools.nix
];
```

**Import in nix-darwin**:

```nix
# darwin/hosts/*/configuration.nix
imports = [
  ../../common/modules/cli-tools.nix
];
```

### `modules/development.nix`

Development toolchains and build tools:

- Languages: Go, Python, Rust, Node.js
- Build tools: make, cmake, pkg-config
- Container tools: docker-compose, dive, lazydocker
- Database clients: psql, sqlite
- Infrastructure: terraform, ansible

Import the same way as cli-tools.nix.

### `modules/gui-apps.nix`

Cross-platform GUI applications:

- Web browsers: firefox, brave
- Terminal emulators: alacritty
- Productivity: obsidian, bitwarden-desktop
- Image editing: gimp
- File sync: syncthing

**Note**: This module only includes GUI apps that work well on **both** Linux and macOS. Platform-specific
GUI apps (like Linux-only X11 tools or macOS-only .app bundles) should stay in platform-specific modules.

Import the same way as cli-tools.nix.

## Usage

### In NixOS

```nix
# nix/nixos/hosts/t470/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ../../common/modules/cli-tools.nix
    ../../common/modules/development.nix
    ../../common/modules/gui-apps.nix
    # ... NixOS-specific modules
  ];

  # NixOS-specific config
  services.xserver.enable = true;
}
```

### In nix-darwin

```nix
# nix/darwin/hosts/macbook/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ../../common/modules/cli-tools.nix
    ../../common/modules/development.nix
    ../../common/modules/gui-apps.nix
    # ... darwin-specific modules
  ];

  # macOS-specific config
  system.defaults.dock.autohide = true;
}
```

## Platform-Specific Overrides

Sometimes you need platform-specific behavior:

```nix
# In shared module
{ pkgs, lib, stdenv, ... }:

{
  environment.systemPackages = with pkgs; [
    # Common packages
    git
    neovim
  ] ++ lib.optionals stdenv.isLinux [
    # Linux-only packages
    xclip
  ] ++ lib.optionals stdenv.isDarwin [
    # macOS-only packages
    # (macOS clipboard is built-in via pbcopy/pbpaste)
  ];
}
```

## Benefits

✅ **DRY**: Define packages once, use everywhere
✅ **Consistency**: Same tools and versions across platforms
✅ **Easy Updates**: Update shared tools in one place
✅ **Type Safety**: Nix catches platform incompatibilities
✅ **Flexibility**: Override per-platform when needed

## What NOT to Share

❌ **System Services**: systemd (Linux) vs launchd (macOS)
❌ **Desktop Environments**: X11/Wayland vs Aqua
❌ **Hardware Config**: boot loaders, kernel modules
❌ **Platform-Specific Apps**: Linux GUI apps vs macOS .app bundles

Keep these in platform-specific modules:

- `nix/nixos/modules/` - NixOS only
- `nix/darwin/modules/` - macOS only

## Migration Path

To migrate existing packages to shared modules:

1. **Identify common packages**: Look for duplicates in `nixos/modules/` and `darwin/modules/`
2. **Extract to `common/modules/`**: Move to appropriate shared module
3. **Update imports**: Add shared module imports to host configs
4. **Remove duplicates**: Delete from platform-specific modules
5. **Test**: Rebuild on both platforms to verify

## Related Documentation

- [nix/README.md](../README.md) - Unified nix overview
- [nix/nixos/README.md](../nixos/README.md) - NixOS-specific docs
- [nix/darwin/README.md](../darwin/README.md) - nix-darwin-specific docs

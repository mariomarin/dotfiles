# NixOS Configuration

Flake-based NixOS for headless hosts. The same flake also holds the darwin config (`malus`).

| Host | Kind | Purpose |
| ---- | ---- | ------- |
| **mitosis** | VM | Headless server, atuin sync server ([docs/ATUIN_SETUP.md](../../docs/ATUIN_SETUP.md)) |
| **symbiont** | WSL | Development on Windows ([hosts/symbiont/README.md](hosts/symbiont/README.md)) |

## Layout

```text
common.nix            # Universal settings (nix, gc, state version)
configuration.nix     # Module imports shared by all hosts
hosts/<host>/         # Hostname, disks/WSL, host services
modules/              # locale, users, services, security, docker, CLI and dev tools
modules/packages/     # Domain-specific tools (cloud, k8s, git utilities)
../common/modules/    # Shared with darwin: cli-tools, development, tmux
```

## Adding Packages

| Package type | Module |
| ------------ | ------ |
| CLI tool for every host | `../common/modules/cli-tools-pkgs.nix` |
| Linux-only CLI tool | `modules/cli-linux.nix` |
| Development tool | `../common/modules/development.nix` |
| Domain-specific tool | `modules/packages/additional-tools.nix` |

Check for duplicates first: `rg "package-name" ..`.

## Commands

| Task | Command |
| ---- | ------- |
| Rebuild this host | `just nixos` (repo root) |
| Deploy mitosis | `just deploy-vm user@mitosis` |
| Update inputs | `nix flake update` |
| Check | `nix flake check` |

See [NixOS manual](https://nixos.org/manual/nixos/stable/) and
[NixOS-WSL](https://github.com/nix-community/NixOS-WSL).

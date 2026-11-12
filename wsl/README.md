# WSL NixOS Setup

Sets up NixOS on WSL2 from Windows. Needs `just` and `nu` (installed by `.install/bootstrap-windows.ps1`).

## Quick Start

From an **Administrator** PowerShell in the chezmoi source directory, after `chezmoi apply` (downloads `wsl/nixos.wsl`):

```powershell
just wsl-setup
```

Re-run after the reboot if WSL2 had to be installed. Each step is skipped when already done:

| Step | Recipe (`just wsl/<recipe>`) | Does |
| ---- | ---------------------------- | ---- |
| 1 | `install-wsl` | `wsl --install` |
| 2 | `import-nixos` | Imports `nixos.wsl` to `%USERPROFILE%\NixOS` |
| 3 | `set-default` | Makes NixOS the default distro |
| 4 | `provision-nixos` | `nixos-rebuild switch` to `symbiont` from the GitHub flake (hostname, user `mario`, packages) |
| 5 | `apply-dotfiles` | Bitwarden login/unlock, then `chezmoi init --apply` (interactive) |

Afterwards: `wsl` to enter, `just nixos-switch` inside WSL to rebuild.

## Other Recipes

| Recipe | Does |
| ------ | ---- |
| `just wsl-check` / `wsl-doctor` | Check WSL / report problems |
| `just wsl-start` / `wsl-stop` | Start / stop NixOS |
| `just wsl/uninstall-nixos` | Unregister NixOS (destroys its data) |

## .wslconfig

Global WSL2 settings live in `%USERPROFILE%\.wslconfig`, outside chezmoi's reach:

```powershell
copy wsl\dot_wslconfig.tmpl $env:USERPROFILE\.wslconfig
wsl --shutdown
```

Per-distro `/etc/wsl.conf` is managed by NixOS (`wsl.wslConf` in
[nix/nixos/hosts/symbiont](../nix/nixos/hosts/symbiont/README.md)), not chezmoi.

See [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) and the
[WSL docs](https://learn.microsoft.com/en-us/windows/wsl/).

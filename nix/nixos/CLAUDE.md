# CLAUDE.md - NixOS Configuration

The only NixOS host is **symbiont** (WSL, headless).
There is no Linux desktop: don't add GUI apps, X11, audio or kanata here. GUI apps for
macOS go in `nix/common/modules/apps.nix` (imported by darwin only).

See [README.md](README.md) for layout, package placement and commands.

## Rules

- **Avoid duplicates**: `rg "package-name" ..` before adding a package.
- **Host specifics** (hostname, disks, WSL, host services) go in `hosts/<host>/configuration.nix`.
- **Shared with darwin** goes in `../common/modules/`; don't use `pkgs.stdenv.isLinux`
  there (infinite recursion with overlays).
- **Flake inputs**: deadnix runs with `--fail`, so remove an input from both `inputs` and
  the `outputs` arguments, then `nix flake lock` to prune the lock file.
- **Module comments** describe purpose, not package lists.
- **Validate**: `nix-instantiate --parse <file>`, then `nix flake check` or
  `nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath`.

## Services

- System services: NixOS modules in `modules/services.nix` or the host config
  (e.g. `services.openssh` on symbiont).
- User units managed by chezmoi: `private_dot_config/systemd/user/`.
- Guidelines: [../../docs/USER_SERVICES.md](../../docs/USER_SERVICES.md).

## WSL (symbiont)

NixOS-WSL module (`nixos-wsl.nixosModules.default`), Docker, SSH server. No boot loader,
no NetworkManager, no hardware services. Details: [hosts/symbiont/README.md](hosts/symbiont/README.md).

## SSH Agent

`programs.ssh.startAgent = true` (`modules/security.nix`):
`SSH_AUTH_SOCK=/run/user/$UID/ssh-agent`.

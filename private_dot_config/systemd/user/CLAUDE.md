# CLAUDE.md - Systemd User Services

User units managed by chezmoi (Linux only). System services on NixOS hosts live in
`nix/nixos/modules/services.nix`.

## Services

| Unit | Purpose | Notes |
| ---- | ------- | ----- |
| `clipper.service` | Clipboard over SSH ([clipper](https://github.com/wincent/clipper)) | `127.0.0.1:8377`, enabled via `default.target.wants/` |
| `syncthing.service` | File sync | Symlinked into `default.target.wants/` |

## Adding a Service

1. Add the unit here, using `%h` for the home directory.
2. Enable it with a symlink in `default.target.wants/`.
3. If it should restart on config changes, add it to `.chezmoidata/services.yaml`.

Debug with `systemctl --user status <unit>` and `journalctl --user -u <unit> -f`.

## Clipper on linux-apt

Not packaged there: download the release binary to `~/.local/bin/clipper`, then
`systemctl --user enable --now clipper.service`.

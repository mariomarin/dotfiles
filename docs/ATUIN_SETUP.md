# Atuin Setup

Encrypted, synced shell history. Server runs on **mitosis** (NixOS `services.atuin`,
`127.0.0.1:8888`, local Postgres); clients reach it over an SSH tunnel.

## Server (mitosis)

Configured in `nix/nixos/hosts/mitosis/configuration.nix`. Deploy with
`just deploy-vm user@mitosis` from `nix/nixos`.

| Check | Command |
| ----- | ------- |
| Status | `systemctl status atuin.service` |
| Logs | `journalctl -u atuin.service -f` |
| Everything | `just atuin-doctor` |

## Clients

1. Tunnel, in `~/.ssh/config`:

   ```ssh
   Host mitosis
     LocalForward 8888 127.0.0.1:8888
   ```

2. Address, in `~/.config/zsh/.zshenv.local` (machine-local, not tracked):

   ```bash
   export ATUIN_SYNC_ADDRESS="http://127.0.0.1:8888"
   ```

3. Log in: `atuin login -u <user> -p <password> -k "<atuin key>"`, then `atuin sync`.

Shell integration (`Ctrl+R`, up-arrow) comes from `~/.config/zsh/atuin-config.zsh`.

## Migrating to a new server

Session tokens belong to each server, so every client must log in again.

1. Deploy mitosis with `openRegistration = true`.
2. On one client (tunnel open): `atuin logout`, `atuin register -u <user> -e <email> -p <password>`,
   then `atuin sync` to upload its history. It keeps its existing key.
3. On every other client: `atuin logout`,
   `atuin login -u <user> -p <password> -k "<key from step 2: atuin key>"`, then `atuin sync`.
4. Set `openRegistration = false` and redeploy.

## Troubleshooting

Run `just atuin-doctor` first: it checks the sync address, server reachability, version
skew, client logs and (on mitosis) the unit and its journal.

| Symptom | Fix |
| ------- | --- |
| Connection refused | Tunnel down: `ssh -L 8888:127.0.0.1:8888 mitosis` |
| Sync succeeds, nothing new | Keys differ: compare `atuin key`, then log out and back in |
| `Ctrl+R` not atuin | `exec zsh`, then `bindkey \| grep atuin` |

See the [Atuin docs](https://docs.atuin.sh/) for configuration.

# Atuin Setup

Encrypted, synced shell history.

| Client | Sync server |
| ------ | ----------- |
| Linux (symbiont) | Self-hosted on symbiont: NixOS `services.atuin`, `127.0.0.1:8888` |
| macOS, Windows, Codespaces | Public server (`api.atuin.sh`, atuin's default) |

`ATUIN_SYNC_ADDRESS` is set by `nix/nixos/hosts/symbiont/configuration.nix`; nothing to
configure elsewhere.

## Server (symbiont)

| Check | Command |
| ----- | ------- |
| Status | `systemctl status atuin.service` |
| Logs | `journalctl -u atuin.service -f` |
| Everything | `just atuin-doctor` |

## First setup

1. `just nixos` on symbiont with `openRegistration = true`.
2. `atuin register -u <user> -e <email> -p <password>`, then `atuin sync`.
3. Set `openRegistration = false` and run `just nixos` again.

Session tokens belong to each server: a client moving between servers needs
`atuin logout`, then `atuin login -u <user> -p <password> -k "$(atuin key)"` and `atuin sync`.

## Troubleshooting

Run `just atuin-doctor` first: it checks the sync address, server reachability, version
skew, client logs and (on symbiont) the unit and its journal.

| Symptom | Fix |
| ------- | --- |
| Sync succeeds, nothing new | Keys differ: compare `atuin key`, then log out and back in |
| `Ctrl+R` not atuin | `exec zsh`, then `bindkey \| grep atuin` |

See the [Atuin docs](https://docs.atuin.sh/) for configuration.

# Atuin Setup

Encrypted, synced shell history using the public server (`api.atuin.sh`, atuin's default).
No server or `sync_address` to configure.

## New machine

1. First machine: `atuin register -u <user> -e <email> -p <password>`, then save `atuin key`.
2. Others: `atuin login -u <user> -p <password> -k "<key>"`, then `atuin sync`.

Shell integration (`Ctrl+R`, up-arrow) comes from `~/.config/zsh/atuin-config.zsh`.

## Troubleshooting

Run `just atuin-doctor` first: it checks login and sync state, server reachability,
version skew and client logs.

| Symptom | Fix |
| ------- | --- |
| Sync succeeds, nothing new | Keys differ: compare `atuin key`, then log out and back in |
| `Ctrl+R` not atuin | `exec zsh`, then `bindkey \| grep atuin` |

See the [Atuin docs](https://docs.atuin.sh/) for configuration.

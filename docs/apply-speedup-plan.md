# Plan: faster apply, flatter just tree, simpler nu scripts

Status: proposed, unmeasured. Step 0 gates the rest.

Basis: [Building on top of chezmoi](https://www.chezmoi.io/developer-guide/building-on-top-of-chezmoi/) —
drive the `chezmoi` binary, inspect with `chezmoi dump` and `chezmoi state`.

## Findings

| Finding | Where |
| ------- | ----- |
| `quick-apply` equals `apply`: `CHEZMOI_SKIP_UPDATES` is set but never read | `chezmoi/justfile` |
| Post-commit hook runs a full apply on every commit, docs-only included | `devenv.nix` |
| `just` has no file targets; sentinels need a helper | all justfiles |
| Tmux reload is wired twice | `run_onchange_after_31_tmux-reload.nu.tmpl`, `.chezmoidata/services.yaml` |
| Rebuild hash lists are hand-kept; an unlisted module never triggers a rebuild | `run_onchange_{nixos,darwin}-rebuild.nu.tmpl` |
| About 30 pass-through recipes each spawn a second `just` and `nu` | root `justfile` |
| `just windows-configure` is called but does not exist | `private_dot_config/topgrade.toml.tmpl` |
| Inline doctor recipes exceed 10 lines, skip `nushell-check` | component justfiles |

## Sentinel layers

| Scope | Mechanism |
| ----- | --------- |
| Inside apply | `run_onchange_` scripts (chezmoi `entryState`); no second layer |
| Whether and what to apply | Last-applied commit in `~/.cache/dotfiles/applied` |
| `just` recipes outside apply | `.scripts/stamp.nu`: input hash vs stored stamp, written on success only |

## Steps

### 0. Baseline

Time each with `hyperfine`; record results here.

```bash
chezmoi status
chezmoi apply --dry-run
chezmoi apply --dry-run --exclude=scripts,externals
chezmoi apply --dry-run ~/.config/tmux
```

Decides whether cost is template rendering (Bitwarden, `output`, `gitHubLatestRelease`), externals, or the tree walk.
Confirms that a single-target apply skips Bitwarden calls.

### 1. Incremental apply (`.scripts/apply.nu`)

| Changed since stamp (`git diff --name-only <stamp> HEAD` + dirty files) | Action |
| ------------------------------------------------------------------------ | ------ |
| Nothing managed (docs, tests, CI) | Skip apply |
| `.chezmoi*`, `.chezmoiscripts/`, `.scripts/` | Full apply |
| Anything else | `chezmoi target-path` each, then `chezmoi apply <targets>` |

- `quick-apply` and the post-commit hook call `apply.nu`; `just apply` stays full and forced.
- Remove the dead `CHEZMOI_SKIP_UPDATES`.
- Missing or unreachable stamp commit: full apply.

### 2. Service reload from `chezmoi state dump`

- `apply.nu` snapshots the `entryState` bucket before and after apply; the difference is the rewritten targets.
- Match against `services.yaml` (read with `open`), reload via the existing functions in `reload-services.nu`.
- Delete `run_onchange_after_reload-services.nu.tmpl`, `run_onchange_after_31_tmux-reload.nu.tmpl`,
  and the `~/.cache/chezmoi-service-checksums.nuon` state.
- Unexpected dump shape: reload all services.

Trade-off: a bare `chezmoi apply` no longer reloads services. Alternative is `[hooks.apply.post]`, which risks
failing before `nu` exists during bootstrap.

### 3. Other chezmoi outputs

| Command | Use |
| ------- | --- |
| `chezmoi data --format json` | Platform and features in nu scripts (`nix/justfile`, `doctor.nu` component list) |
| `chezmoi dump` | CI-only check that every template renders; holds secrets, never cached |
| `output "git" "-C" .chezmoi.sourceDir "rev-parse" "HEAD:nix"` | One tree hash replaces the hand-kept hash lists |

The tree hash only sees committed changes, matching the commit-then-apply workflow.

### 4. `stamp.nu` for just recipes

| Recipe | Inputs |
| ------ | ------ |
| `test-nu` (inside `check`) | All `.nu` files |
| `nvim sync` | `lazy-lock.json` |
| `krew-sync` | `dot_krewfile.tmpl` |
| NixOS-WSL download | Release tag (replaces `nixos.wsl.version`) |

### 5. Just modules

- Replace pass-through recipes with `mod chezmoi`, `mod nvim 'private_dot_config/nvim'`, and so on.
- Recipes become `just nvim sync` instead of `just nvim-sync`.
- Update callers: `doctor.nu`, `topgrade.toml.tmpl`, `devenv.nix` hooks, README, CLAUDE.md.
- Fix `windows-configure` in the same pass.
- Check the installed `just` version supports aliases to module recipes.

### 6. Nu scripts

- `doctor.nu all` and `tests/run.nu`: `par-each`, print after collecting.
- Move the inline doctor recipes to `.nu` files.

## Order

| Step | Depends on | Expected payoff |
| ---- | ---------- | --------------- |
| 0 | — | Numbers |
| 1 | 0 | Largest: most commits skip or shrink the apply |
| 2 | 1 | About 100 fewer lines of template and state code |
| 3 | — | Removes drift in rebuild triggers |
| 4 | — | Faster `just check` |
| 5 | — | One process per recipe, about 80 fewer lines |
| 6 | — | Faster doctor and tests |

## Open decisions

| Decision | Recommendation |
| -------- | -------------- |
| Service reloads only via `just`, not bare `chezmoi apply` (step 2) | Accept |
| Rename `just nvim-sync` to `just nvim sync` (step 5) | Accept |

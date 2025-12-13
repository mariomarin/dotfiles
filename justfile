# Set default shell to nushell for cross-platform scripting

set shell := ["nu", "-c"]

# Auto-load environment variables from .env and .env.local
# This makes BW_SESSION available to all just targets

set dotenv-load := true

# Default recipe (runs when you type `just`)
default: chezmoi-quick-apply

# Bitwarden session management (uses ~/.config/nushell/modules/bitwarden)

# Setup: login and unlock Bitwarden (first-time setup)
bw-setup:
    #!/usr/bin/env nu
    print "🔐 Logging into Bitwarden..."
    bw login
    print "\n✅ Login successful. Unlocking vault..."
    use ~/.config/nushell/modules/bitwarden
    bitwarden unlock

bw-unlock:
    use ~/.config/nushell/modules/bitwarden; bitwarden unlock

# Reload direnv to load BW_SESSION from .env.local
bw-reload:
    use ~/.config/nushell/modules/bitwarden; bitwarden reload

# Cloudflare Quick Tunnels (no auth required for quick tunnels)

# List active tunnels via Cloudflare API
tunnel-list:
    nu .scripts/cloudflare-tunnel.nu list

# Start SSH tunnel (default port 22)
tunnel-ssh PORT="22":
    nu .scripts/cloudflare-tunnel.nu ssh --port {{ PORT }}

# Start HTTP tunnel
tunnel-http PORT:
    nu .scripts/cloudflare-tunnel.nu http {{ PORT }}

# Start custom quick tunnel
tunnel-quick SERVICE="ssh://localhost:22":
    nu .scripts/cloudflare-tunnel.nu quick {{ SERVICE }}

# Show tunnel status
tunnel-status:
    nu .scripts/cloudflare-tunnel.nu status

# Stop running tunnel
tunnel-stop:
    nu .scripts/cloudflare-tunnel.nu stop

# Krew plugin management

# Sync krew plugins from Krewfile
krew-sync:
    nu .scripts/krew.nu sync

# List installed krew plugins
krew-list:
    nu .scripts/krew.nu list

# Install a krew plugin and add to Krewfile
krew-install PLUGIN:
    nu .scripts/krew.nu install {{ PLUGIN }}

# Linting and formatting targets
# Note: Formatting is also configured as git pre-commit hooks in devenv.nix
# These targets are for manual formatting outside of git workflow

# Run all linting checks
lint: lint-lua lint-nix lint-nu lint-shell
    print "✅ All linting checks passed"

# Check Lua files with stylua
lint-lua:
    nu .scripts/lint.nu lua

# Check Nix files syntax
lint-nix:
    nu .scripts/lint.nu nix

# Check Nushell scripts syntax
lint-nu:
    nu .scripts/lint.nu nu

# Check shell scripts with shellcheck
lint-shell:
    nu .scripts/lint.nu shell

# Format all files
format: format-lua format-nix format-shell format-yaml format-markdown format-justfile format-others
    print "✨ All formatting complete"

# Format Lua files with stylua
format-lua:
    nu .scripts/format.nu lua

# Format Nix files with nixpkgs-fmt
format-nix:
    nu .scripts/format.nu nix

# Format shell scripts with shfmt
format-shell:
    nu .scripts/format.nu shell

# Format YAML files with yamlfmt
format-yaml:
    nu .scripts/format.nu yaml

# Format Markdown files with markdownlint
format-markdown:
    nu .scripts/format.nu markdown

# Format justfiles
format-justfile:
    nu .scripts/format.nu justfile

# Format JSON and TOML files with biome
format-others:
    nu .scripts/format.nu others

# Start development shell
dev:
    nu .scripts/dev.nu

# Run all checks
check: lint test-nu
    print "✅ All checks passed"

# Run nushell tests
test-nu:
    nu .scripts/tests/run.nu

# Health checks
health: health-summary
    print ""
    print "Run 'just health-all' for detailed checks of all subsystems"

# System health summary
health-summary:
    nu .scripts/health.nu summary

# Full system health check
health-all:
    nu .scripts/health.nu all

# Pass-through targets to subdirectories
nixos-switch:
    @just nix/nixos/switch

nixos-health:
    @just nix/nixos/health

chezmoi-apply:
    @just chezmoi/apply

chezmoi-quick-apply:
    @just chezmoi/quick-apply

chezmoi-diff:
    @just chezmoi/diff

chezmoi-health:
    @just chezmoi/health

nvim-sync:
    @just private_dot_config/nvim/sync

nvim-health:
    @just private_dot_config/nvim/health

tmux-reload:
    @just private_dot_config/tmux/reload

tmux-health:
    @just private_dot_config/tmux/health

zim-update:
    @just private_dot_config/zim/update

zim-health:
    @just private_dot_config/zim/health

zim-recompile:
    @just private_dot_config/zim/recompile

topgrade-update:
    @just private_dot_config/topgrade/update

topgrade-status:
    @just private_dot_config/topgrade/status

topgrade-plugins:
    @just private_dot_config/topgrade/plugins

topgrade-system:
    @just private_dot_config/topgrade/system

# Convenience aliases

alias nixos := nixos-switch
alias apply := chezmoi-apply
alias quick-apply := chezmoi-quick-apply
alias diff := chezmoi-diff
alias nvim := nvim-sync
alias tmux := tmux-reload
alias zim := zim-update
alias update := topgrade-update
alias update-status := topgrade-status
alias update-plugins := topgrade-plugins
alias update-system := topgrade-system

# Multi-machine deployment
vm-switch:
    @just nix/nixos/vm-switch

vm-test:
    @just nix/nixos/vm-test

deploy-vm TARGET_HOST BUILD_HOST:
    @just nix/nixos/deploy-vm TARGET_HOST={{ TARGET_HOST }} BUILD_HOST={{ BUILD_HOST }}

# WSL NixOS setup (Windows only)
wsl-setup:
    @just wsl/setup

wsl-check:
    @just wsl/check-wsl

wsl-health:
    @just wsl/health

wsl-start:
    @just wsl/start-nixos

wsl-stop:
    @just wsl/stop-nixos

# nix-darwin setup (macOS only)
darwin-first-time:
    @just nix/darwin/first-time

darwin-switch:
    @just nix/darwin/switch

darwin-health:
    @just nix/darwin/health

# Windows package management (Windows only)
# Packages are applied automatically by chezmoi when configuration.dsc.yaml changes
# To force re-apply: chezmoi apply
# Convenience aliases

alias darwin := darwin-switch

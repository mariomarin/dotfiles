# Set default shell to nushell for cross-platform scripting

set shell := ["nu", "-c"]

# Auto-load environment variables from .env and .env.local
# This makes BW_SESSION available to all just targets

set dotenv-load

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

# Git operations using gh CLI authentication

# Push to remote using gh CLI credentials
git-push BRANCH="main":
    #!/usr/bin/env nu
    print $"Pushing (ansi blue){{ BRANCH }}(ansi reset) to origin..."
    with-env {GIT_ASKPASS: "gh", GIT_CREDENTIAL_HELPER: ""} {
        git push origin {{ BRANCH }}
    }

# Pull from remote
git-pull BRANCH="main":
    #!/usr/bin/env nu
    print $"Pulling (ansi blue){{ BRANCH }}(ansi reset) from origin..."
    git pull origin {{ BRANCH }}

# Sync (pull then push)
git-sync BRANCH="main":
    just git-pull {{ BRANCH }}
    just git-push {{ BRANCH }}

# Jujutsu (jj) operations

# Push via jj-hp (runs hooks, then pushes)
jj-push:
    jj-hp push

# Push directly without hooks
jj-push-fast:
    jj git push

# Cloudflare Quick Tunnels (temporary, anonymous, no auth required)

# Start SSH tunnel (default port 22)
tunnel-ssh PORT="22":
    nu .scripts/cloudflare-tunnel.nu ssh --port {{ PORT }}

# Start HTTP tunnel
tunnel-http PORT:
    nu .scripts/cloudflare-tunnel.nu http {{ PORT }}

# Start custom quick tunnel
tunnel-quick SERVICE="ssh://localhost:22":
    nu .scripts/cloudflare-tunnel.nu quick {{ SERVICE }}

# Get tunnel URL
tunnel-url:
    nu .scripts/cloudflare-tunnel.nu url

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

# Format all files (mutating)
format:
    prek run --all-files

# Start development shell
dev:
    nu .scripts/dev.nu

# Check files changed since main (mirrors CI); test-nu runs on all scripts
check: test-nu
    prek run --from-ref origin/main

# Run nushell tests
test-nu:
    nu .scripts/tests/run.nu

# Doctor: report only problems with actionable fixes
doctor:
    nu .scripts/doctor.nu all

# Pass-through targets to subdirectories

# Apply the right nix configuration for the current platform
nix:
    @just nix/

nixos-switch:
    @just nix/nixos/switch

nixos-doctor:
    @just nix/nixos/doctor

chezmoi-apply:
    @just chezmoi/apply

chezmoi-quick-apply:
    @just chezmoi/quick-apply

chezmoi-diff:
    @just chezmoi/diff

chezmoi-doctor:
    @just chezmoi/doctor

nvim-sync:
    @just private_dot_config/nvim/sync

nvim-doctor:
    @just private_dot_config/nvim/doctor

tmux-reload:
    @just private_dot_config/tmux/reload

tmux-doctor:
    @just private_dot_config/tmux/doctor

zim-update:
    @just private_dot_config/zim/update

zim-doctor:
    @just private_dot_config/zim/doctor

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
alias push := git-push
alias pull := git-pull
alias sync := git-sync

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

wsl-doctor:
    @just wsl/doctor

wsl-start:
    @just wsl/start-nixos

wsl-stop:
    @just wsl/stop-nixos

# nix-darwin setup (macOS only)
darwin-first-time:
    @just nix/darwin/first-time

darwin-switch:
    @just nix/darwin/switch

darwin-doctor:
    @just nix/darwin/doctor

kanata-doctor:
    nu .scripts/kanata-doctor.nu

# Windows package management (Windows only)
# Packages are applied automatically by chezmoi when configuration.dsc.yaml changes
# To force re-apply: chezmoi apply
# Convenience aliases

alias darwin := darwin-switch

# Set default shell to nushell for cross-platform scripting

set shell := ["nu", "-c"]

# Default recipe (runs when you type `just`)
default: chezmoi-quick-apply

# Bitwarden session management
bw-unlock:
    #!/usr/bin/env nu
    if not (term is-terminal) {
        print "❌ Error: This target requires interactive input (a terminal)"
        print "   Run this command directly from your terminal, not in a pipeline or script"
        exit 1
    }
    let bw_status = (do { bw status | from json | get status } | complete | get stdout | str trim | default "unauthenticated")
    let bw_session = if $bw_status == "unlocked" {
        print "✅ Vault is already unlocked"
        let session = (do { bw unlock --raw --passwordenv BW_PASSWORD } | complete | get stdout | str trim)
        if ($session | is-empty) {
            print "⚠️  Could not get session token. You may need to run 'bw lock' and try again."
            exit 1
        }
        $session
    } else if $bw_status == "locked" {
        print "🔓 Unlocking Bitwarden vault..."
        (bw unlock --raw | str trim)
    } else {
        print "❌ Bitwarden is not logged in. Please run 'bw login' first"
        exit 1
    }
    $"export BW_SESSION=\"($bw_session)\"" | save -f .envrc.local
    $"BW_SESSION=\"($bw_session)\"" | save -f .env
    print "✅ Session saved to .env and .envrc.local"
    print "💡 Run 'just bw-reload' to reload direnv and load the session"

# Direnv management (convenience wrapper)

# Note: Named bw-reload for workflow clarity, but this is a general direnv command
bw-reload:
    #!/usr/bin/env nu
    print "🔄 Reloading direnv environment..."
    direnv allow
    direnv reload
    print "✅ Environment reloaded"
    if ($env.BW_SESSION? | default "" | is-not-empty) {
        print "✅ BW_SESSION is loaded"
    } else {
        print "⚠️  BW_SESSION not found in environment"
        print "   You may need to restart your shell or run: source .envrc.local"
    }

# Linting and formatting targets
# Note: Formatting is also configured as git pre-commit hooks in devenv.nix
# These targets are for manual formatting outside of git workflow

# Run all linting checks
lint: lint-lua lint-nix lint-shell
    print "✅ All linting checks passed"

# Check Lua files with stylua
lint-lua:
    #!/usr/bin/env nu
    print "🔍 Checking Lua files with stylua..."
    if (which stylua | is-empty) {
        print "⚠️  stylua not found. Run 'devenv shell' or 'direnv allow' to load development environment"
        exit 0
    }
    cd private_dot_config/nvim
    let result = (do { stylua --check . } | complete)
    if $result.exit_code != 0 {
        print "❌ Lua files need formatting. Run 'just format-lua' to fix."
        exit 1
    }

# Check Nix files syntax
lint-nix:
    #!/usr/bin/env nu
    print "🔍 Checking Nix files syntax..."
    let nix_files = (glob **/*.nix)
    let result = ($nix_files | each {|file| do { nix-instantiate --parse $file } | complete } | all {|r| $r.exit_code == 0 })
    if $result {
        print "✅ Nix syntax valid"
    } else {
        print "❌ Nix syntax errors found"
        exit 1
    }

# Check shell scripts with shellcheck
lint-shell:
    #!/usr/bin/env nu
    print "🔍 Checking shell scripts with shellcheck..."
    if (which shellcheck | is-empty) {
        print "⚠️  shellcheck not found. Run 'devenv shell' or 'direnv allow' to load development environment"
        exit 0
    }
    let sh_files = (glob **/*.sh)
    $sh_files | each {|file| shellcheck $file }
    print "✅ Shell scripts valid"

# Format all files
format: format-lua format-nix format-shell format-yaml format-markdown format-justfile format-others
    print "✨ All formatting complete"

# Format Lua files with stylua
format-lua:
    #!/usr/bin/env nu
    print "📝 Formatting Lua files with stylua..."
    if (which stylua | is-empty) {
        print "⚠️  stylua not found. Run 'devenv shell' or 'direnv allow' to load development environment"
        exit 0
    }
    cd private_dot_config/nvim
    stylua .
    print "✅ Lua files formatted"

# Format Nix files with nixpkgs-fmt
format-nix:
    #!/usr/bin/env nu
    print "📝 Formatting Nix files with nixpkgs-fmt..."
    if (which nixpkgs-fmt | is-empty) {
        print "⚠️  nixpkgs-fmt not found. Run 'devenv shell' or 'direnv allow' to load development environment"
        exit 0
    }
    glob **/*.nix | each {|file| nixpkgs-fmt $file }
    print "✅ Nix files formatted"

# Format shell scripts with shfmt
format-shell:
    #!/usr/bin/env nu
    print "📝 Formatting shell scripts with shfmt..."
    if (which shfmt | is-empty) {
        print "⚠️  shfmt not found. Run 'devenv shell' or 'direnv allow' to load development environment"
        exit 0
    }
    shfmt -w -i 2 -ci -sr -kp .
    print "✅ Shell scripts formatted"

# Format YAML files with yamlfmt
format-yaml:
    #!/usr/bin/env nu
    print "📝 Formatting YAML files with yamlfmt..."
    if (which yamlfmt | is-empty) {
        print "⚠️  yamlfmt not found. Run 'direnv allow' to load development environment"
        exit 0
    }
    glob **/*.{yml,yaml} | where {|f| $f !~ "/.git/" and $f !~ "/node_modules/" } | each {|file| yamlfmt $file }
    print "✅ YAML files formatted"

# Format Markdown files with markdownlint
format-markdown:
    #!/usr/bin/env nu
    print "📝 Formatting Markdown files with markdownlint..."
    if (which markdownlint | is-empty) {
        print "⚠️  markdownlint not found. Run 'direnv allow' to load development environment"
        exit 0
    }
    do { markdownlint --fix "**/*.md" --ignore node_modules --ignore .git } | complete | ignore
    print "✅ Markdown files formatted"

# Format justfiles
format-justfile:
    #!/usr/bin/env nu
    print "📝 Formatting justfiles..."
    if (which just | is-empty) {
        print "⚠️  just not found"
        exit 0
    }
    glob **/justfile | each {|file| cd ($file | path dirname); just --fmt --unstable }
    print "✅ Justfiles formatted"

# Format JSON and TOML files with biome
format-others:
    #!/usr/bin/env nu
    print "📝 Formatting JSON and TOML files with biome..."
    if (which biome | is-empty) {
        print "⚠️  biome not found. Run 'direnv allow' to load development environment"
        exit 0
    }
    biome format --write .
    print "✅ JSON and TOML files formatted"

# Start development shell
dev:
    #!/usr/bin/env nu
    print "🚀 Starting development shell..."
    devenv shell

# Run all checks
check: lint
    print "✅ All checks passed"

# Health checks
health: health-summary
    print ""
    print "Run 'just health-all' for detailed checks of all subsystems"

# System health summary
health-summary:
    #!/usr/bin/env nu
    print "🏥 System Health Summary"
    print "========================"
    print ""
    print "🔍 Quick Status:"
    let nixos_result = (do { nixos-version } | complete)
    let nixos = if $nixos_result.exit_code == 0 { $nixos_result.stdout | lines | first | split row ' ' | first 2 | str join ' ' } else { '❌ not available' }
    let chezmoi_result = (do { chezmoi --version } | complete)
    let chezmoi = if $chezmoi_result.exit_code == 0 { $chezmoi_result.stdout | lines | first | split row ',' | first } else { '❌ not installed' }
    let nvim_result = (do { nvim --version } | complete)
    let nvim = if $nvim_result.exit_code == 0 { $nvim_result.stdout | lines | first } else { '❌ not installed' }
    let tmux_result = (do { tmux -V } | complete)
    let tmux = if $tmux_result.exit_code == 0 { $tmux_result.stdout | str trim } else { '❌ not installed' }
    let zsh_result = (do { zsh --version } | complete)
    let zsh = if $zsh_result.exit_code == 0 { $zsh_result.stdout | lines | first } else { '❌ not installed' }
    print $"  NixOS:   ($nixos)"
    print $"  Chezmoi: ($chezmoi)"
    print $"  Neovim:  ($nvim)"
    print $"  Tmux:    ($tmux)"
    print $"  Zsh:     ($zsh)"

# Full system health check
health-all:
    #!/usr/bin/env nu
    print "🏥 Full System Health Check"
    print "==========================="
    print ""
    do { just nixos-health } | complete | ignore
    print ""
    do { just chezmoi-health } | complete | ignore
    print ""
    do { just nvim-health } | complete | ignore
    print ""
    do { just tmux-health } | complete | ignore
    print ""
    do { just zim-health } | complete | ignore

# Pass-through targets to subdirectories
nixos-switch:
    @just nixos/switch

nixos-health:
    @just nixos/health

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
    @just nixos/vm-switch

vm-test:
    @just nixos/vm-test

deploy-vm TARGET_HOST BUILD_HOST:
    @just nixos/deploy-vm TARGET_HOST={{ TARGET_HOST }} BUILD_HOST={{ BUILD_HOST }}

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
    @just darwin/first-time

darwin-switch:
    @just darwin/switch

darwin-health:
    @just darwin/health

# Convenience aliases

alias darwin := darwin-switch

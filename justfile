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
    @echo "✅ All linting checks passed"

# Check Lua files with stylua
lint-lua:
    #!/usr/bin/env bash
    echo "🔍 Checking Lua files with stylua..."
    if ! command -v stylua >/dev/null 2>&1; then
        echo "⚠️  stylua not found. Run 'devenv shell' or 'direnv allow' to load development environment"
        exit 0
    fi
    cd private_dot_config/nvim && stylua --check . || {
        echo "❌ Lua files need formatting. Run 'just format-lua' to fix."
        exit 1
    }

# Check Nix files syntax
lint-nix:
    #!/usr/bin/env bash
    echo "🔍 Checking Nix files syntax..."
    if find . -name "*.nix" -exec nix-instantiate --parse {} \; > /dev/null 2>&1; then
        echo "✅ Nix syntax valid"
    else
        echo "❌ Nix syntax errors found"
        exit 1
    fi

# Check shell scripts with shellcheck
lint-shell:
    #!/usr/bin/env bash
    echo "🔍 Checking shell scripts with shellcheck..."
    if ! command -v shellcheck >/dev/null 2>&1; then
        echo "⚠️  shellcheck not found. Run 'devenv shell' or 'direnv allow' to load development environment"
        exit 0
    fi
    find . -name "*.sh" -type f -exec shellcheck {} \;
    echo "✅ Shell scripts valid"

# Format all files
format: format-lua format-nix format-shell format-yaml format-markdown format-justfile format-others
    @echo "✨ All formatting complete"

# Format Lua files with stylua
format-lua:
    #!/usr/bin/env bash
    echo "📝 Formatting Lua files with stylua..."
    if ! command -v stylua >/dev/null 2>&1; then
        echo "⚠️  stylua not found. Run 'devenv shell' or 'direnv allow' to load development environment"
        exit 0
    fi
    cd private_dot_config/nvim && stylua .
    echo "✅ Lua files formatted"

# Format Nix files with nixpkgs-fmt
format-nix:
    #!/usr/bin/env bash
    echo "📝 Formatting Nix files with nixpkgs-fmt..."
    if ! command -v nixpkgs-fmt >/dev/null 2>&1; then
        echo "⚠️  nixpkgs-fmt not found. Run 'devenv shell' or 'direnv allow' to load development environment"
        exit 0
    fi
    find . -name "*.nix" -exec nixpkgs-fmt {} \;
    echo "✅ Nix files formatted"

# Format shell scripts with shfmt
format-shell:
    #!/usr/bin/env bash
    echo "📝 Formatting shell scripts with shfmt..."
    if ! command -v shfmt >/dev/null 2>&1; then
        echo "⚠️  shfmt not found. Run 'devenv shell' or 'direnv allow' to load development environment"
        exit 0
    fi
    shfmt -w -i 2 -ci -sr -kp .
    echo "✅ Shell scripts formatted"

# Format YAML files with yamlfmt
format-yaml:
    #!/usr/bin/env bash
    echo "📝 Formatting YAML files with yamlfmt..."
    if ! command -v yamlfmt >/dev/null 2>&1; then
        echo "⚠️  yamlfmt not found. Run 'direnv allow' to load development environment"
        exit 0
    fi
    find . -name "*.yml" -o -name "*.yaml" | grep -v "/.git/" | grep -v "/node_modules/" | xargs -r yamlfmt
    echo "✅ YAML files formatted"

# Format Markdown files with markdownlint
format-markdown:
    #!/usr/bin/env bash
    echo "📝 Formatting Markdown files with markdownlint..."
    if ! command -v markdownlint >/dev/null 2>&1; then
        echo "⚠️  markdownlint not found. Run 'direnv allow' to load development environment"
        exit 0
    fi
    markdownlint --fix "**/*.md" --ignore node_modules --ignore .git || true
    echo "✅ Markdown files formatted"

# Format justfiles
format-justfile:
    #!/usr/bin/env bash
    echo "📝 Formatting justfiles..."
    if ! command -v just >/dev/null 2>&1; then
        echo "⚠️  just not found"
        exit 0
    fi
    find . -name "justfile" -type f -exec sh -c 'cd "$(dirname "{}")" && just --fmt --unstable' \;
    echo "✅ Justfiles formatted"

# Format JSON and TOML files with biome
format-others:
    #!/usr/bin/env bash
    echo "📝 Formatting JSON and TOML files with biome..."
    if ! command -v biome >/dev/null 2>&1; then
        echo "⚠️  biome not found. Run 'direnv allow' to load development environment"
        exit 0
    fi
    biome format --write .
    echo "✅ JSON and TOML files formatted"

# Start development shell
dev:
    #!/usr/bin/env nu
    print "🚀 Starting development shell..."
    devenv shell

# Run all checks
check: lint
    @echo "✅ All checks passed"

# Health checks
health: health-summary
    @echo ""
    @echo "Run 'just health-all' for detailed checks of all subsystems"

# System health summary
health-summary:
    #!/usr/bin/env bash
    echo "🏥 System Health Summary"
    echo "========================"
    echo ""
    echo "🔍 Quick Status:"
    echo -n "  NixOS:   "; nixos-version 2>/dev/null | cut -d' ' -f1,2 || echo "❌ not available"
    echo -n "  Chezmoi: "; chezmoi --version 2>/dev/null | head -1 | cut -d, -f1 || echo "❌ not installed"
    echo -n "  Neovim:  "; nvim --version 2>/dev/null | head -1 || echo "❌ not installed"
    echo -n "  Tmux:    "; tmux -V 2>/dev/null || echo "❌ not installed"
    echo -n "  Zsh:     "; zsh --version 2>/dev/null | head -1 || echo "❌ not installed"

# Full system health check
health-all:
    #!/usr/bin/env bash
    echo "🏥 Full System Health Check"
    echo "==========================="
    echo ""
    just nixos-health || true
    echo ""
    just chezmoi-health || true
    echo ""
    just nvim-health || true
    echo ""
    just tmux-health || true
    echo ""
    just zim-health || true

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

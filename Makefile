all: chezmoi/quick-apply

# Bitwarden session management
bw-unlock:
	@if [ ! -t 0 ]; then \
		echo "❌ Error: This target requires interactive input (a terminal)"; \
		echo "   Run this command directly from your terminal, not in a pipeline or script"; \
		exit 1; \
	fi
	@BW_STATUS=$$(bw status 2>/dev/null | jq -r '.status' 2>/dev/null || echo "unauthenticated"); \
	if [ "$$BW_STATUS" = "unlocked" ]; then \
		echo "✅ Vault is already unlocked"; \
		BW_SESSION=$$(bw unlock --raw --passwordenv BW_PASSWORD 2>/dev/null || echo ""); \
		if [ -z "$$BW_SESSION" ]; then \
			echo "⚠️  Could not get session token. You may need to run 'bw lock' and try again."; \
			exit 1; \
		fi; \
	elif [ "$$BW_STATUS" = "locked" ]; then \
		echo "🔓 Unlocking Bitwarden vault..."; \
		BW_SESSION=$$(bw unlock --raw); \
	else \
		echo "❌ Bitwarden is not logged in. Please run 'bw login' first"; \
		exit 1; \
	fi && \
	echo "export BW_SESSION=\"$$BW_SESSION\"" > .envrc.local && \
	echo "BW_SESSION=\"$$BW_SESSION\"" > .env && \
	echo "✅ Session saved to .env and .envrc.local" && \
	echo "💡 Run 'make bw-reload' to reload direnv and load the session"

# Direnv management (convenience wrapper)
# Note: Named bw-reload for workflow clarity, but this is a general direnv command
bw-reload:
	@echo "🔄 Reloading direnv environment..."
	@direnv allow
	@direnv reload
	@echo "✅ Environment reloaded"
	@if [ -n "$$BW_SESSION" ]; then \
		echo "✅ BW_SESSION is loaded"; \
	else \
		echo "⚠️  BW_SESSION not found in environment"; \
		echo "   You may need to restart your shell or run: source .envrc.local"; \
	fi

# Linting and formatting targets
# Note: Formatting is also configured as git pre-commit hooks in devenv.nix
# These targets are for manual formatting outside of git workflow
lint: lint-lua lint-nix lint-shell
	@echo "✅ All linting checks passed"

lint-lua:
	@echo "🔍 Checking Lua files with stylua..."
	@command -v stylua >/dev/null 2>&1 || { echo "⚠️  stylua not found. Run 'devenv shell' or 'direnv allow' to load development environment"; exit 0; }
	@cd private_dot_config/nvim && stylua --check . || { echo "❌ Lua files need formatting. Run 'make format-lua' to fix."; exit 1; }

lint-nix:
	@echo "🔍 Checking Nix files syntax..."
	@find . -name "*.nix" -exec nix-instantiate --parse {} \; > /dev/null 2>&1 && echo "✅ Nix syntax valid" || (echo "❌ Nix syntax errors found" && exit 1)

lint-shell:
	@echo "🔍 Checking shell scripts with shellcheck..."
	@command -v shellcheck >/dev/null 2>&1 || { echo "⚠️  shellcheck not found. Run 'devenv shell' or 'direnv allow' to load development environment"; exit 0; }
	@find . -name "*.sh" -type f -exec shellcheck {} \;
	@echo "✅ Shell scripts valid"

format: format-lua format-nix format-shell format-yaml format-markdown format-others
	@echo "✨ All formatting complete"

format-lua:
	@echo "📝 Formatting Lua files with stylua..."
	@command -v stylua >/dev/null 2>&1 || { echo "⚠️  stylua not found. Run 'devenv shell' or 'direnv allow' to load development environment"; exit 0; }
	@cd private_dot_config/nvim && stylua .
	@echo "✅ Lua files formatted"

format-nix:
	@echo "📝 Formatting Nix files with nixpkgs-fmt..."
	@command -v nixpkgs-fmt >/dev/null 2>&1 || { echo "⚠️  nixpkgs-fmt not found. Run 'devenv shell' or 'direnv allow' to load development environment"; exit 0; }
	@find . -name "*.nix" -exec nixpkgs-fmt {} \;
	@echo "✅ Nix files formatted"

format-shell:
	@echo "📝 Formatting shell scripts with shfmt..."
	@command -v shfmt >/dev/null 2>&1 || { echo "⚠️  shfmt not found. Run 'devenv shell' or 'direnv allow' to load development environment"; exit 0; }
	@shfmt -w -i 2 -ci -sr -kp .
	@echo "✅ Shell scripts formatted"

format-yaml:
	@echo "📝 Formatting YAML files with yamlfmt..."
	@command -v yamlfmt >/dev/null 2>&1 || { echo "⚠️  yamlfmt not found. Run 'direnv allow' to load development environment"; exit 0; }
	@find . -name "*.yml" -o -name "*.yaml" | grep -v "/.git/" | grep -v "/node_modules/" | xargs -r yamlfmt
	@echo "✅ YAML files formatted"

format-markdown:
	@echo "📝 Formatting Markdown files with markdownlint..."
	@command -v markdownlint >/dev/null 2>&1 || { echo "⚠️  markdownlint not found. Run 'direnv allow' to load development environment"; exit 0; }
	@markdownlint --fix "**/*.md" --ignore node_modules --ignore .git || true
	@echo "✅ Markdown files formatted"

format-others:
	@echo "📝 Formatting JSON and TOML files with biome..."
	@command -v biome >/dev/null 2>&1 || { echo "⚠️  biome not found. Run 'direnv allow' to load development environment"; exit 0; }
	@biome format --write .
	@echo "✅ JSON and TOML files formatted"

# Development environment
dev:
	@echo "🚀 Starting development shell..."
	@devenv shell

check: lint
	@echo "✅ All checks passed"

# Health checks
health: health-summary
	@echo ""
	@echo "Run 'make health-all' for detailed checks of all subsystems"

health-summary:
	@echo "🏥 System Health Summary"
	@echo "========================"
	@echo ""
	@echo "🔍 Quick Status:"
	@echo -n "  NixOS:   "; nixos-version 2>/dev/null | cut -d' ' -f1,2 || echo "❌ not available"
	@echo -n "  Chezmoi: "; chezmoi --version 2>/dev/null | head -1 | cut -d, -f1 || echo "❌ not installed"
	@echo -n "  Neovim:  "; nvim --version 2>/dev/null | head -1 || echo "❌ not installed"
	@echo -n "  Tmux:    "; tmux -V 2>/dev/null || echo "❌ not installed"
	@echo -n "  Zsh:     "; zsh --version 2>/dev/null | head -1 || echo "❌ not installed"

health-all:
	@echo "🏥 Full System Health Check"
	@echo "==========================="
	@echo ""
	@$(MAKE) -s nixos/health || true
	@echo ""
	@$(MAKE) -s chezmoi/health || true
	@echo ""
	@$(MAKE) -s nvim/health || true
	@echo ""
	@$(MAKE) -s tmux/health || true
	@echo ""
	@$(MAKE) -s zim/health || true

# Pass-through targets to subdirectories
nixos/%:
	@cd nixos && just $*

chezmoi/%:
	@cd chezmoi && just $*

nvim/%:
	@$(MAKE) -C private_dot_config/nvim $*

tmux/%:
	@$(MAKE) -C private_dot_config/tmux $*

zim/%:
	@$(MAKE) -C private_dot_config/zim $*

topgrade/%:
	@$(MAKE) -C private_dot_config/topgrade $*

# Convenience aliases
nixos: nixos/switch
apply: chezmoi/apply
quick-apply: chezmoi/quick-apply
diff: chezmoi/diff
nvim: nvim/sync

# Multi-machine deployment aliases
vm-switch: nixos/vm/switch
vm-test: nixos/vm/test
deploy-vm: 
	@$(MAKE) -C nixos deploy-vm TARGET_HOST=$(TARGET_HOST) BUILD_HOST=$(BUILD_HOST)
tmux: tmux/reload
zim: zim/update
update: topgrade/update
update-status: topgrade/status
update-plugins: topgrade/plugins
update-system: topgrade/system

# All targets are phony (no actual files created)
.PHONY: $(shell sed -n -e '/^[^[:space:]#.*][^:=]*:/{s/:.*//;p}' $(MAKEFILE_LIST))

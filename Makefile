all: chezmoi/apply

# Update all system packages and plugins
update:
	@echo "🔄 Running topgrade to update everything..."
	@topgrade --no-retry
	@echo "✅ All updates complete"

# Update only specific components
update-plugins:
	@echo "🔄 Updating plugins..."
	@topgrade --only tmux vim --no-retry
	@echo "✅ Plugin updates complete"

update-system:
	@echo "🔄 Updating system packages..."
	@topgrade --only system nix --no-retry
	@echo "✅ System updates complete"

# Linting and formatting targets
lint: lint-lua lint-nix lint-shell
	@echo "✅ All linting checks passed"

lint-lua:
	@echo "🔍 Checking Lua files with stylua..."
	@if command -v stylua >/dev/null 2>&1; then \
		cd private_dot_config/nvim && stylua --check . || (echo "❌ Lua files need formatting. Run 'make format-lua' to fix." && exit 1); \
	else \
		echo "⚠️  stylua not found. Run 'devenv shell' or 'direnv allow' to load development environment"; \
	fi

lint-nix:
	@echo "🔍 Checking Nix files syntax..."
	@find . -name "*.nix" -exec nix-instantiate --parse {} \; > /dev/null 2>&1 && echo "✅ Nix syntax valid" || (echo "❌ Nix syntax errors found" && exit 1)

lint-shell:
	@echo "🔍 Checking shell scripts with shellcheck..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		find . -name "*.sh" -type f -exec shellcheck {} \; && echo "✅ Shell scripts valid"; \
	else \
		echo "⚠️  shellcheck not found. Run 'devenv shell' or 'direnv allow' to load development environment"; \
	fi

format: format-lua format-nix format-shell format-others
	@echo "✨ All formatting complete"

format-lua:
	@echo "📝 Formatting Lua files with stylua..."
	@if command -v stylua >/dev/null 2>&1; then \
		cd private_dot_config/nvim && stylua . && echo "✅ Lua files formatted"; \
	else \
		echo "⚠️  stylua not found. Run 'devenv shell' or 'direnv allow' to load development environment"; \
	fi

format-nix:
	@echo "📝 Formatting Nix files with nixpkgs-fmt..."
	@if command -v nixpkgs-fmt >/dev/null 2>&1; then \
		find . -name "*.nix" -exec nixpkgs-fmt {} \; && echo "✅ Nix files formatted"; \
	else \
		echo "⚠️  nixpkgs-fmt not found. Run 'devenv shell' or 'direnv allow' to load development environment"; \
	fi

format-shell:
	@echo "📝 Formatting shell scripts with shfmt..."
	@if command -v shfmt >/dev/null 2>&1; then \
		shfmt -w -i 2 -ci -sr -kp . && echo "✅ Shell scripts formatted"; \
	else \
		echo "⚠️  shfmt not found. Run 'devenv shell' or 'direnv allow' to load development environment"; \
	fi

format-others:
	@echo "📝 Formatting Markdown, JSON, TOML, YAML files with biome..."
	@if command -v biome >/dev/null 2>&1; then \
		biome format --write . && echo "✅ Other files formatted"; \
	else \
		echo "⚠️  biome not found. Run 'direnv allow' to load development environment"; \
	fi

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
	@$(MAKE) -C nixos $*

chezmoi/%:
	@$(MAKE) -C chezmoi $*

nvim/%:
	@$(MAKE) -C private_dot_config/nvim $*

tmux/%:
	@$(MAKE) -C private_dot_config/tmux $*

zim/%:
	@$(MAKE) -C private_dot_config/zim $*

# Convenience aliases
nixos: nixos/switch
apply: chezmoi/apply
quick-apply: chezmoi/quick-apply
diff: chezmoi/diff
nvim: nvim/sync
tmux: tmux/reload
zim: zim/update

.PHONY: all update update-plugins update-system lint lint-lua lint-nix lint-shell format format-lua format-nix format-shell format-others dev check health health-summary health-all nixos apply quick-apply diff nvim tmux zim

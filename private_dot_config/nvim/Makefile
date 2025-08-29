# Neovim configuration management
.PHONY: sync update clean health plugins lint format

# Sync/install plugins
sync:
	nvim --headless "+Lazy! sync" +qa

# Update plugins
update:
	nvim --headless "+Lazy! update" +qa

# Clean unused plugins
clean:
	nvim --headless "+Lazy! clean" +qa

# Health check
health:
	@echo "🔍 Neovim Health Check"
	@echo "===================="
	@echo -n "✓ Neovim version: "; nvim --version | head -1
	@echo -n "✓ Config location: "; echo ~/.config/nvim
	@echo -n "✓ LazyVim plugins: "; find ~/.local/share/nvim/lazy -maxdepth 1 -type d | wc -l | awk '{print $$1-1 " installed"}'
	@echo -n "✓ Treesitter parsers: "; find ~/.local/share/nvim/lazy/nvim-treesitter/parser -name "*.so" 2>/dev/null | wc -l | awk '{print $$1 " installed"}'
	@echo -n "✓ Mason packages: "; ls ~/.local/share/nvim/mason/packages 2>/dev/null | wc -l | awk '{print $$1 " installed"}'
	@echo -n "✓ Config syntax: "; nvim --headless -c "try | source init.lua | echo 'valid' | catch | echo 'invalid' | endtry" -c "qa!" 2>/dev/null || echo "checking..."
	@echo ""
	@echo "For detailed health check, run: make health-full"

health-full:
	nvim "+checkhealth" "+qa"

# Show plugin status
plugins:
	nvim --headless "+Lazy" "+qa"

# Lint Lua files
lint:
	@if command -v stylua >/dev/null 2>&1; then \
		stylua --check . || (echo "❌ Lua files need formatting. Run 'make format' to fix." && exit 1); \
	else \
		echo "⚠️  stylua not found"; \
	fi

# Format Lua files
format:
	@if command -v stylua >/dev/null 2>&1; then \
		stylua . && echo "✅ Lua files formatted"; \
	else \
		echo "⚠️  stylua not found"; \
	fi

# Default: sync plugins
all: sync
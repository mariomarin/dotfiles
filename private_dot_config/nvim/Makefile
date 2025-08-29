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

# Check health
health:
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
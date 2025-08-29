# Zim framework management
# All targets are phony
.PHONY: $(shell sed -n -e '/^[^[:space:]#.*][^:=]*:/{s/:.*//;p}' $(MAKEFILE_LIST))

# Install Zim
install:
	curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh

# Update Zim modules
update:
	zimfw update

# Uninstall Zim modules
uninstall:
	zimfw uninstall

# Upgrade Zim itself
upgrade:
	zimfw upgrade

# Clean Zim cache and compiled files
clean:
	zimfw clean
	zimfw clean-compiled

# Compile Zim modules for faster loading
compile:
	zimfw compile

# List installed modules
list:
	zimfw list

# Show Zim version
version:
	zimfw version

# Build custom completions
completions:
	@echo "Regenerating custom completions..."
	@for module in modules/*/init.zsh; do \
		echo "Processing $${module}..."; \
		zsh -c "source $${module}"; \
	done

# Health check
health:
	@echo "🔍 Zim Health Check"
	@echo "=================="
	@echo -n "✓ Zim installed: "; test -d ~/.zim && echo "yes" || echo "❌ no"
	@echo -n "✓ Zim version: "; zimfw version 2>/dev/null | head -1 || echo "not installed"
	@echo -n "✓ Config file: "; test -f ~/.config/zim/zimrc && echo "exists" || echo "❌ missing"
	@echo -n "✓ Modules installed: "; ls ~/.zim/modules 2>/dev/null | wc -l | awk '{print $$1 " modules"}' || echo "0 modules"
	@echo -n "✓ Custom modules: "; ls modules 2>/dev/null | wc -l | awk '{print $$1 " custom"}' || echo "0 custom"
	@echo -n "✓ Compiled files: "; find ~/.zim -name "*.zwc" 2>/dev/null | wc -l | awk '{print $$1 " files"}'
	@echo -n "✓ Completion cache: "; ls ~/.cache/zim/compdump* 2>/dev/null | wc -l | awk '{print $$1 " files"}' || echo "0 files"
	@echo -n "✓ Zsh version: "; zsh --version | head -1
	@echo ""

# Default: update modules
all: update
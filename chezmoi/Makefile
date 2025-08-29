# Chezmoi operations
# All targets are phony
.PHONY: $(shell sed -n -e '/^[^[:space:]#.*][^:=]*:/{s/:.*//;p}' $(MAKEFILE_LIST))

# Apply dotfiles changes
apply:
	chezmoi apply

# Show what would change
diff:
	chezmoi diff

# Quick apply without updates
quick-apply:
	CHEZMOI_SKIP_UPDATES=1 chezmoi apply

# Initialize chezmoi with repository
init:
	chezmoi init "${CHEZMOI_REPO:-git@github.com:mariomarin/dotfiles.git}" --apply

# Install chezmoi
install:
	curl -sfL https://git.io/chezmoi | sh

# Show status
status:
	chezmoi status

# Add a file to chezmoi
add:
	@[ -n "$(FILE)" ] || { echo "Usage: make add FILE=<path>"; exit 1; }
	@chezmoi add $(FILE)

# Edit a managed file
edit:
	@[ -n "$(FILE)" ] || { echo "Usage: make edit FILE=<path>"; exit 1; }
	@chezmoi edit $(FILE)

# Update from repository
update:
	chezmoi git pull -- --rebase && chezmoi diff

# Health check
health:
	@echo "🔍 Chezmoi Health Check"
	@echo "======================"
	@echo -n "✓ Chezmoi version: "; chezmoi --version | head -1
	@echo -n "✓ Source directory: "; chezmoi source-path
	@echo -n "✓ Config file: "; test -f ~/.config/chezmoi/chezmoi.toml && echo "exists" || echo "using defaults"
	@echo -n "✓ Managed files: "; chezmoi managed | wc -l
	@echo -n "✓ Modified files: "; chezmoi status 2>/dev/null | wc -l | awk '{print $$1 " files"}'
	@echo -n "✓ Git status: "; cd $$(chezmoi source-path) && git status --porcelain | wc -l | awk '{if ($$1 == 0) print "clean"; else print $$1 " changes"}'
	@echo -n "✓ Git remote: "; cd $$(chezmoi source-path) && git remote get-url origin 2>/dev/null || echo "no remote"
	@echo -n "✓ Auto commit: "; grep -q "autoCommit.*true" ~/.config/chezmoi/chezmoi.toml 2>/dev/null && echo "enabled" || echo "disabled"
	@echo ""

# Default target
all: apply
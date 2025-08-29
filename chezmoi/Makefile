# Chezmoi operations
.PHONY: apply diff init install status add edit update

# Apply dotfiles changes
apply:
	chezmoi apply -v

# Show what would change
diff:
	chezmoi diff

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
	@echo "Usage: make add FILE=<path>"
	@[ -n "$(FILE)" ] && chezmoi add $(FILE) || echo "Please specify FILE=<path>"

# Edit a managed file
edit:
	@echo "Usage: make edit FILE=<path>"
	@[ -n "$(FILE)" ] && chezmoi edit $(FILE) || echo "Please specify FILE=<path>"

# Update from repository
update:
	chezmoi git pull -- --rebase && chezmoi diff

# Default target
all: apply
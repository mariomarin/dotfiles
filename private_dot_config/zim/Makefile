# Zim framework management
.PHONY: install update uninstall upgrade clean compile list version

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

# Default: update modules
all: update
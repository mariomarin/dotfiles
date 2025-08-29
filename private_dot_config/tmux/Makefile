# Tmux configuration management
.PHONY: reload plugins-install plugins-update plugins-clean status kill-server

# Reload tmux configuration
reload:
	tmux source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

# Install TPM plugins
plugins-install:
	~/.local/share/tmux/plugins/tpm/bin/install_plugins

# Update TPM plugins
plugins-update:
	~/.local/share/tmux/plugins/tpm/bin/update_plugins all

# Clean unused plugins
plugins-clean:
	~/.local/share/tmux/plugins/tpm/bin/clean_plugins

# Show tmux status
status:
	@tmux list-sessions 2>/dev/null || echo "No tmux sessions running"
	@tmux list-windows 2>/dev/null || true
	@tmux list-panes 2>/dev/null || true

# Kill tmux server
kill-server:
	tmux kill-server

# Default: reload config
all: reload
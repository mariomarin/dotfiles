# Tmux configuration management
.PHONY: reload plugins-install plugins-update plugins-clean status kill-server health

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

# Health check
health:
	@echo "🔍 Tmux Health Check"
	@echo "=================="
	@echo -n "✓ Tmux version: "; tmux -V
	@echo -n "✓ Config file: "; test -f ~/.config/tmux/tmux.conf && echo "exists" || echo "❌ missing"
	@echo -n "✓ TPM installed: "; test -d ~/.local/share/tmux/plugins/tpm && echo "yes" || echo "❌ no"
	@echo -n "✓ Plugins installed: "; ls ~/.local/share/tmux/plugins 2>/dev/null | wc -l | awk '{print $$1 " plugins"}'
	@echo -n "✓ Server running: "; tmux list-sessions &>/dev/null && echo "yes" || echo "no"
	@echo -n "✓ Sessions: "; tmux list-sessions 2>/dev/null | wc -l | awk '{print $$1 " active"}' || echo "0 active"
	@echo -n "✓ Key bindings: "; tmux list-keys | wc -l | awk '{print $$1 " configured"}'
	@echo -n "✓ Environment: "; tmux show-environment TERM 2>/dev/null | cut -d= -f2 || echo "not in tmux"
	@echo ""

# Default: reload config
all: reload
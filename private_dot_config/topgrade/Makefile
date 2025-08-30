.PHONY: all update status force plugins system

# Default target
all: update

# Run topgrade manually (interactive)
update:
	@echo "🔄 Running topgrade..."
	@topgrade --no-retry

# Run topgrade in background via systemd
background:
	@echo "🔄 Starting topgrade in background..."
	@systemctl --user start topgrade.service
	@echo "✅ Topgrade started - check progress with 'journalctl --user -u topgrade -f'"

# Show timer status
status:
	@echo "📊 Topgrade timer status:"
	@systemctl --user status topgrade.timer --no-pager || echo "Timer not enabled"
	@echo ""
	@echo "📅 Next scheduled run:"
	@systemctl --user list-timers topgrade.timer --no-pager || true
	@echo ""
	@echo "📜 Last run logs (if any):"
	@journalctl --user -u topgrade.service -n 10 --no-pager || true

# Force update (bypasses timer)
force:
	@echo "🔄 Force running topgrade..."
	@topgrade
	@echo "✅ All updates complete"

# Update only plugins
plugins:
	@echo "🔄 Updating plugins..."
	@topgrade --only tmux vim --no-retry
	@echo "✅ Plugin updates complete"

# Update only system packages
system:
	@echo "🔄 Updating system packages..."
	@topgrade --only system nix --no-retry
	@echo "✅ System updates complete"
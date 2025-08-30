.PHONY: all update status force plugins system

# Default target
all: update

# Run topgrade manually
update:
	@echo "🔄 Running topgrade manually..."
	@systemctl --user start topgrade.service || topgrade --no-retry
	@echo "✅ All updates complete"

# Show timer status
status:
	@echo "📊 Topgrade timer status:"
	@systemctl --user status topgrade.timer --no-pager || echo "Timer not enabled"
	@echo ""
	@echo "📅 Next scheduled run:"
	@systemctl --user list-timers topgrade.timer --no-pager || true

# Force update (bypasses timer)
force:
	@echo "🔄 Force running topgrade..."
	@topgrade --no-retry
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
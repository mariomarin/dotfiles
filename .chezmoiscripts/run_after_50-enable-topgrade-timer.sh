#!/usr/bin/env bash
# Enable topgrade timer for automatic updates every 3 days

set -euo pipefail

# Reload systemd user configuration
systemctl --user daemon-reload

# Enable and start the topgrade timer
systemctl --user enable topgrade.timer
systemctl --user start topgrade.timer

echo "✅ Topgrade timer enabled (runs every 3 days)"
echo "   Status: systemctl --user status topgrade.timer"
echo "   Manual run: systemctl --user start topgrade.service"
echo "   Force run: make update-force"

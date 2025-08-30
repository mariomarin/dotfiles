#!/usr/bin/env bash
# Enable topgrade timer for automatic updates every 3 days

set -euo pipefail

# Reload systemd user configuration
systemctl --user daemon-reload

# Enable and start the topgrade timer
systemctl --user enable topgrade.timer
systemctl --user start topgrade.timer

echo "✅ Topgrade timer enabled (runs every 3 days)"
echo "   Status: make update-status"
echo "   Manual run: make update"
echo "   Force run: make topgrade/force"

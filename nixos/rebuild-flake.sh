#!/usr/bin/env bash
# Script to rebuild NixOS using flakes

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}This script should not be run as root!${NC}"
   echo "Use: ./rebuild-flake.sh [switch|boot|test|build]"
   exit 1
fi

# Default action
ACTION="${1:-switch}"

# Validate action
case "$ACTION" in
    switch|boot|test|build|dry-build|dry-activate)
        ;;
    *)
        echo -e "${RED}Invalid action: $ACTION${NC}"
        echo "Valid actions: switch, boot, test, build, dry-build, dry-activate"
        exit 1
        ;;
esac

echo -e "${GREEN}Rebuilding NixOS with flakes...${NC}"
echo -e "${YELLOW}Action: $ACTION${NC}"

# Path to the flake
FLAKE_PATH="/home/mario/.local/share/chezmoi/nixos"

# Check if flake.nix exists
if [[ ! -f "$FLAKE_PATH/flake.nix" ]]; then
    echo -e "${RED}Error: flake.nix not found at $FLAKE_PATH${NC}"
    exit 1
fi

# Run the rebuild
echo -e "${GREEN}Running: sudo nixos-rebuild $ACTION --flake $FLAKE_PATH#nixos${NC}"
sudo nixos-rebuild "$ACTION" --flake "$FLAKE_PATH#nixos" --show-trace

echo -e "${GREEN}Rebuild complete!${NC}"
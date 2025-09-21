#!/usr/bin/env bash
# Deploy NixOS configuration to different hosts

set -euo pipefail

usage() {
    cat << EOF
Usage: $0 [COMMAND] [OPTIONS]

Commands:
    local [HOST]     Build and switch on local machine
    remote HOST      Build locally and deploy to remote host
    test [HOST]      Build and test without switching
    
Hosts:
    nixos           ThinkPad T470 (default)
    vm-headless     Headless VM configuration
    
Options:
    --target-host USER@HOST    SSH target for remote deployment
    --build-host USER@HOST     Build on remote host instead of locally
    
Examples:
    $0 local                   # Build default (nixos) locally
    $0 local vm-headless       # Build VM config locally
    $0 remote vm-headless --target-host admin@192.168.1.100
    $0 test nixos              # Test T470 config without switching
EOF
}

# Default values
COMMAND="${1:-local}"
HOST="${2:-nixos}"
TARGET_HOST=""
BUILD_HOST=""

# Parse additional options
shift 2 || true
while [[ $# -gt 0 ]]; do
    case $1 in
        --target-host)
            TARGET_HOST="$2"
            shift 2
            ;;
        --build-host)
            BUILD_HOST="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
  esac
done

# Validate host
if [[ ! "$HOST" =~ ^(nixos|vm-headless)$ ]]; then
    echo "Error: Unknown host '$HOST'"
    echo "Available hosts: nixos, vm-headless"
    exit 1
fi

# Execute command
case $COMMAND in
    local)
        echo "Building and switching to $HOST configuration locally..."
        sudo nixos-rebuild switch --flake ".#$HOST"
        ;;

    remote)
        if [[ -z "$TARGET_HOST" ]]; then
            echo "Error: --target-host required for remote deployment"
            usage
            exit 1
    fi

        echo "Deploying $HOST configuration to $TARGET_HOST..."

        if [[ -n "$BUILD_HOST" ]]; then
            # Build on remote host
            nixos-rebuild switch --flake ".#$HOST" \
                --target-host "$TARGET_HOST" \
                --build-host "$BUILD_HOST" \
                --use-remote-sudo
    else
            # Build locally, deploy remotely
            nixos-rebuild switch --flake ".#$HOST" \
                --target-host "$TARGET_HOST" \
                --use-remote-sudo
    fi
        ;;

    test)
        echo "Testing $HOST configuration..."
        sudo nixos-rebuild test --flake ".#$HOST"
        ;;

    *)
        echo "Unknown command: $COMMAND"
        usage
        exit 1
        ;;
esac

echo "Done!"

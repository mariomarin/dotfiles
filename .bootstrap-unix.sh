#!/usr/bin/env bash
# Bootstrap script for Unix-like systems (macOS, Linux)
# Chezmoi pre-hook: Runs before reading source state
# NOTE: This is NOT a template - must handle OS detection itself

set -euo pipefail

case "$(uname -s)" in
  Darwin)
    # macOS bootstrap

    # Install Nix with Determinate Systems installer (includes flakes by default)
    if ! command -v nix > /dev/null 2>&1; then
      echo "Installing Nix with Determinate Systems installer..." >&2
      echo "This installer enables flakes by default and provides better macOS integration" >&2
      curl -fsSL https://install.determinate.systems/nix | sh -s -- install
      echo "⚠️  Please restart your shell and run 'chezmoi apply' again" >&2
      exit 0
    fi

    # Install Bitwarden CLI via Nix (avoid Homebrew dependency)
    if ! command -v bw > /dev/null 2>&1; then
      echo "Installing Bitwarden CLI via Nix..." >&2
      nix profile install nixpkgs#bitwarden-cli
    fi
    ;;

  Linux)
    # NixOS-only bootstrap

    # Verify we're on NixOS
    if [ ! -f /etc/os-release ] || ! grep -q "ID=nixos" /etc/os-release; then
      echo "❌ This configuration only supports NixOS on Linux" >&2
      echo "   For other distributions, consider using NixOS or WSL with NixOS" >&2
      exit 1
    fi

    # Verify Bitwarden CLI is installed
    if ! command -v bw > /dev/null 2>&1; then
      echo "❌ Bitwarden CLI not found. Please add to your NixOS configuration:" >&2
      echo "   environment.systemPackages = [ pkgs.bitwarden-cli ];" >&2
      echo "" >&2
      echo "   Or install temporarily:" >&2
      echo "   nix-env -iA nixos.bitwarden-cli" >&2
      exit 1
    fi
    ;;

  *)
    echo "❌ Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

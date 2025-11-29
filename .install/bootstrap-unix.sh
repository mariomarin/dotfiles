#!/usr/bin/env bash
# Bootstrap script for Unix-like systems (macOS, Linux)
# Chezmoi pre-hook: Runs before reading source state
# NOTE: This is NOT a template - must handle OS detection itself

set -euo pipefail

case "$(uname -s)" in
  Darwin)
    # macOS bootstrap

    # Verify Nix is installed
    if ! command -v nix > /dev/null 2>&1; then
      echo "❌ Nix not found. Please install Nix first:" >&2
      echo "" >&2
      echo "   curl -sfL https://install.determinate.systems/nix | sh -s -- install" >&2
      echo "" >&2
      echo "   Then clone dotfiles and use the bootstrap shell:" >&2
      echo "   git clone https://github.com/mariomarin/dotfiles.git ~/.local/share/chezmoi" >&2
      echo "   cd ~/.local/share/chezmoi" >&2
      echo "   nix-shell .install/shell.nix" >&2
      exit 1
    fi

    # Verify Nushell is available
    if ! command -v nu > /dev/null 2>&1; then
      echo "❌ Nushell not found. Bootstrap requires Nushell and Bitwarden CLI." >&2
      echo "" >&2
      echo "   Use bootstrap shell (recommended):" >&2
      echo "   cd ~/.local/share/chezmoi" >&2
      echo "   nix-shell .install/shell.nix" >&2
      exit 1
    fi

    # Verify Bitwarden CLI is available
    if ! command -v bw > /dev/null 2>&1; then
      echo "❌ Bitwarden CLI not found. Bootstrap requires Nushell and Bitwarden CLI." >&2
      echo "" >&2
      echo "   Use bootstrap shell (recommended):" >&2
      echo "   cd ~/.local/share/chezmoi" >&2
      echo "   nix-shell .install/shell.nix" >&2
      exit 1
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

    # Verify Nushell is installed
    if ! command -v nu > /dev/null 2>&1; then
      echo "❌ Nushell not found. Bootstrap requires Nushell and Bitwarden CLI." >&2
      echo "" >&2
      echo "   Option 1 - Use bootstrap shell (recommended for first-time setup):" >&2
      echo "   cd ~/.local/share/chezmoi" >&2
      echo "   nix-shell .install/shell.nix" >&2
      echo "" >&2
      echo "   Option 2 - Add to your NixOS configuration permanently:" >&2
      echo "   environment.systemPackages = [ pkgs.nushell pkgs.bitwarden-cli ];" >&2
      echo "   sudo nixos-rebuild switch" >&2
      exit 1
    fi

    # Verify Bitwarden CLI is installed
    if ! command -v bw > /dev/null 2>&1; then
      echo "❌ Bitwarden CLI not found. Bootstrap requires Nushell and Bitwarden CLI." >&2
      echo "" >&2
      echo "   Option 1 - Use bootstrap shell (recommended for first-time setup):" >&2
      echo "   cd ~/.local/share/chezmoi" >&2
      echo "   nix-shell .install/shell.nix" >&2
      echo "" >&2
      echo "   Option 2 - Add to your NixOS configuration permanently:" >&2
      echo "   environment.systemPackages = [ pkgs.nushell pkgs.bitwarden-cli ];" >&2
      echo "   sudo nixos-rebuild switch" >&2
      exit 1
    fi
    ;;

  *)
    echo "❌ Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

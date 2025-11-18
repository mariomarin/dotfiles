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
    # Linux/NixOS bootstrap

    # Detect NixOS
    if [ -f /etc/os-release ] && grep -q "ID=nixos" /etc/os-release; then
      if ! command -v bw > /dev/null 2>&1; then
        echo "❌ Bitwarden CLI not found. Please add to your NixOS configuration:" >&2
        echo "   environment.systemPackages = [ pkgs.bitwarden-cli ];" >&2
        exit 1
      fi
    else
      # Non-NixOS Linux: Install static binary
      if [ ! -d "$HOME/.local/bin" ]; then
        mkdir -p "$HOME/.local/bin"
      fi

      # Install Bitwarden CLI if not present
      if ! command -v bw > /dev/null 2>&1; then
        echo "Installing Bitwarden CLI (static binary)..." >&2
        echo "⚠️  Note: This will not auto-update. Consider installing via your package manager." >&2

        # Detect architecture
        case "$(uname -m)" in
          x86_64)
            ARCH="x86_64"
            ;;
          aarch64 | arm64)
            ARCH="aarch64"
            ;;
          *)
            echo "❌ Unsupported architecture: $(uname -m)" >&2
            exit 1
            ;;
        esac

        # Download and install
        BW_VERSION="2024.12.0"
        BW_URL="https://github.com/bitwarden/clients/releases/download/cli-v${BW_VERSION}/bw-linux-${ARCH}-${BW_VERSION}.zip"

        curl -fsSL "$BW_URL" -o /tmp/bw.zip
        unzip -q -o /tmp/bw.zip -d "$HOME/.local/bin"
        chmod +x "$HOME/.local/bin/bw"
        rm /tmp/bw.zip

        echo "Bitwarden CLI installed to ~/.local/bin/bw" >&2
        echo "To update: Download latest from https://github.com/bitwarden/clients/releases" >&2
      fi
    fi
    ;;

  *)
    echo "❌ Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

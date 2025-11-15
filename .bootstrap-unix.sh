#!/usr/bin/env bash
# Bootstrap script for Unix-like systems (macOS, Linux)
# Chezmoi pre-hook: Runs before reading source state
# NOTE: This is NOT a template - must handle OS detection itself

set -euo pipefail

echo "🚀 Running bootstrap for $(uname -s)..."

case "$(uname -s)" in
  Darwin)
    # macOS bootstrap
    echo "📦 macOS bootstrap..."

    # Install Homebrew if not present
    if ! command -v brew > /dev/null 2>&1; then
      echo "  Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
      echo "  ✓ Homebrew already installed"
    fi

    # Install Nix for nix-darwin
    if ! command -v nix > /dev/null 2>&1; then
      echo "  Installing Nix (for nix-darwin)..."
      curl -L https://nixos.org/nix/install | sh -s -- --daemon
      echo "  ⚠️  Please restart your shell and run 'chezmoi apply' again"
      exit 0
    else
      echo "  ✓ Nix already installed"
    fi

    # Install Bitwarden CLI
    if ! command -v bw > /dev/null 2>&1; then
      echo "  Installing Bitwarden CLI..."
      brew install bitwarden-cli
    else
      echo "  ✓ Bitwarden CLI already installed"
    fi
    ;;

  Linux)
    # Linux/NixOS bootstrap
    echo "📦 Linux bootstrap..."

    if [ ! -d "$HOME/.local/bin" ]; then
      mkdir -p "$HOME/.local/bin"
    fi

    # Install Bitwarden CLI if not present
    if ! command -v bw > /dev/null 2>&1; then
      echo "  Installing Bitwarden CLI..."

      # Detect architecture
      case "$(uname -m)" in
        x86_64)
          ARCH="x86_64"
          ;;
        aarch64 | arm64)
          ARCH="aarch64"
          ;;
        *)
          echo "  ❌ Unsupported architecture: $(uname -m)"
          exit 1
          ;;
      esac

      # Download and install
      BW_VERSION="2024.12.0"
      BW_URL="https://github.com/bitwarden/clients/releases/download/cli-v${BW_VERSION}/bw-linux-${ARCH}-${BW_VERSION}.zip"

      echo "    Downloading from: $BW_URL"
      curl -fsSL "$BW_URL" -o /tmp/bw.zip
      unzip -q -o /tmp/bw.zip -d "$HOME/.local/bin"
      chmod +x "$HOME/.local/bin/bw"
      rm /tmp/bw.zip

      echo "  ✓ Bitwarden CLI installed to ~/.local/bin/bw"
    else
      echo "  ✓ Bitwarden CLI already installed"
    fi

    # Note: NixOS system installation happens via nixos/justfile
    ;;

  *)
    echo "❌ Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

echo "✅ Bootstrap complete for Unix systems"

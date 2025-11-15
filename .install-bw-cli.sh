#!/usr/bin/env bash
# Chezmoi pre-hook: Install Bitwarden CLI before reading source state
# This runs every time chezmoi reads source state, so exit fast if nothing to do
# NOTE: This is NOT a template - it must handle OS detection itself

set -euo pipefail

# Exit immediately if bw is already in PATH
if command -v bw > /dev/null 2>&1; then
  exit 0
fi

echo "📦 Installing Bitwarden CLI..."

case "$(uname -s)" in
  Darwin)
    # macOS - use homebrew
    if ! command -v brew > /dev/null 2>&1; then
      echo "❌ Homebrew not found. Please install: https://brew.sh"
      exit 1
    fi
    brew install bitwarden-cli
    ;;

  Linux)
    # Linux - download official binary
    if [ ! -d "$HOME/.local/bin" ]; then
      mkdir -p "$HOME/.local/bin"
    fi

    # Detect architecture
    case "$(uname -m)" in
      x86_64)
        ARCH="x86_64"
        ;;
      aarch64 | arm64)
        ARCH="aarch64"
        ;;
      *)
        echo "❌ Unsupported architecture: $(uname -m)"
        exit 1
        ;;
    esac

    # Download and install
    BW_VERSION="2024.12.0"
    BW_URL="https://github.com/bitwarden/clients/releases/download/cli-v${BW_VERSION}/bw-linux-${ARCH}-${BW_VERSION}.zip"

    echo "  Downloading from: $BW_URL"
    curl -fsSL "$BW_URL" -o /tmp/bw.zip
    unzip -q -o /tmp/bw.zip -d "$HOME/.local/bin"
    chmod +x "$HOME/.local/bin/bw"
    rm /tmp/bw.zip

    echo "✅ Bitwarden CLI installed to ~/.local/bin/bw"
    echo "💡 Make sure ~/.local/bin is in your PATH"
    ;;

  MINGW* | MSYS* | CYGWIN*)
    # Windows (Git Bash or similar)
    # Check if winget is available
    if ! command -v winget.exe > /dev/null 2>&1; then
      echo "❌ winget not found. Please install App Installer from Microsoft Store."
      exit 1
    fi

    echo "  Installing via winget..."
    winget.exe install --id Bitwarden.CLI --exact --silent --accept-package-agreements --accept-source-agreements
    ;;

  *)
    echo "❌ Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

echo "✅ Bitwarden CLI installed successfully"

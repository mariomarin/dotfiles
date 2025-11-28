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
      # Non-NixOS Linux: Prefer system package manager
      if ! command -v bw > /dev/null 2>&1; then
        echo "⚠️  Bitwarden CLI not found" >&2
        echo "" >&2
        echo "RECOMMENDED: Install via your package manager for auto-updates:" >&2
        echo "" >&2

        # Detect distro and suggest package manager
        if command -v apt > /dev/null 2>&1; then
          echo "  # Debian/Ubuntu (via Snap)" >&2
          echo "  sudo snap install bw" >&2
        elif command -v dnf > /dev/null 2>&1; then
          echo "  # Fedora/RHEL (via Flatpak)" >&2
          echo "  flatpak install flathub com.bitwarden.desktop" >&2
        elif command -v pacman > /dev/null 2>&1; then
          echo "  # Arch Linux (via AUR)" >&2
          echo "  yay -S bitwarden-cli" >&2
        fi

        echo "" >&2
        echo "FALLBACK: Installing static binary to ~/.local/bin/bw (manual updates required)" >&2
        echo "         Press Ctrl+C to cancel and install via package manager instead" >&2
        sleep 3

        # Create directory
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
            echo "❌ Unsupported architecture: $(uname -m)" >&2
            exit 1
            ;;
        esac

        # Fetch latest version from GitHub API
        echo "Fetching latest version..." >&2
        BW_VERSION=$(curl -fsSL https://api.github.com/repos/bitwarden/clients/releases/latest | grep '"tag_name"' | sed -E 's/.*"cli-v([^"]+)".*/\1/')

        if [ -z "$BW_VERSION" ]; then
          echo "❌ Failed to fetch latest version. Using fallback: 2024.12.0" >&2
          BW_VERSION="2024.12.0"
        else
          echo "Latest version: $BW_VERSION" >&2
        fi

        BW_URL="https://github.com/bitwarden/clients/releases/download/cli-v${BW_VERSION}/bw-linux-${ARCH}-${BW_VERSION}.zip"

        # Download and install
        echo "Downloading from $BW_URL..." >&2
        curl -fsSL "$BW_URL" -o /tmp/bw.zip
        unzip -q -o /tmp/bw.zip -d "$HOME/.local/bin"
        chmod +x "$HOME/.local/bin/bw"
        rm /tmp/bw.zip

        echo "✅ Bitwarden CLI $BW_VERSION installed to ~/.local/bin/bw" >&2
        echo "⚠️  To update: Re-run chezmoi apply or install via package manager" >&2
      fi
    fi
    ;;

  *)
    echo "❌ Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

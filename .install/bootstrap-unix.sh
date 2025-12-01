#!/usr/bin/env bash
# Bootstrap script for Unix-like systems (macOS, Linux)
# Chezmoi pre-hook: Runs before reading source state
# NOTE: This is NOT a template - must handle OS detection itself

set -euo pipefail

# Helper functions
error() {
  echo "" >&2
  echo "❌ $1" >&2
  shift
  for line in "$@"; do
    echo "   $line" >&2
  done
  echo "" >&2
  exit 1
}

run_nix_shell() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  echo "" >&2
  echo "📝 Entering nix-shell with all dependencies..." >&2
  echo "" >&2

  # If running as pre-hook, just verify tools are available
  # Otherwise, exec into nix-shell
  if [ -n "${CHEZMOI_SOURCE_DIR:-}" ]; then
    # Running as chezmoi pre-hook - verify we have required tools
    if ! nix-shell "$script_dir/shell.nix" --run "command -v bw && command -v yq && command -v chezmoi" > /dev/null 2>&1; then
      error "Required tools not available in nix-shell" \
        "This is unexpected - please report this issue"
    fi
    echo "✅ All required tools available via nix-shell" >&2
  else
    # Running directly - enter nix-shell
    exec nix-shell "$script_dir/shell.nix"
  fi
}

echo "🚀 Running Unix bootstrap..." >&2

case "$(uname -s)" in
  Darwin)
    # macOS - verify Nix is installed
    if ! command -v nix > /dev/null 2>&1; then
      error "Nix not found. Install Nix first:" \
        "" \
        "curl -sfL https://install.determinate.systems/nix | sh -s -- install" \
        "" \
        "Then run this script again:" \
        "./.install/bootstrap-unix.sh"
    fi

    echo "✅ Nix is installed" >&2
    run_nix_shell
    ;;

  Linux)
    # NixOS-only - verify we're on NixOS
    if [ ! -f /etc/os-release ] || ! grep -q "ID=nixos" /etc/os-release; then
      error "This configuration only supports NixOS on Linux" \
        "For other distributions, consider using NixOS or WSL with NixOS"
    fi

    echo "✅ NixOS detected" >&2
    run_nix_shell
    ;;

  *)
    error "Unsupported OS: $(uname -s)"
    ;;
esac

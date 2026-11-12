#!/bin/sh
# Bootstrap script for Unix-like systems
# Usage: curl -sfL .../bootstrap-unix.sh | sh
set -eu

# Output helpers
error() {
  printf "\n❌ %s\n" "$1" >&2
  exit 1
}
success() { printf "✅ %s\n" "$1" >&2; }
step() { printf "\n==> %s\n" "$1" >&2; }

# Detection helpers
is_nixos() { grep -q "ID=nixos" /etc/os-release 2> /dev/null; }
is_darwin() { [ "$(uname -s)" = "Darwin" ]; }

# Platform detection
# - Darwin → darwin (nix-darwin)
# - Linux + NixOS → nixos
# - Linux + other → linux-apt (Codespaces, devcontainers: no Nix, no root)
detect_platform() {
  if is_darwin; then
    echo "darwin"
  else
    is_nixos && echo "nixos" || echo "linux-apt"
  fi
}

# Idempotent installers
ensure_nix() {
  command -v nix > /dev/null && {
    success "Nix installed"
    return 0
  }
  step "Install Nix"
  curl -sfL https://install.determinate.systems/nix | sh -s -- install
  # shellcheck source=/dev/null
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  success "Nix installed"
}

ensure_homebrew() {
  command -v brew > /dev/null && {
    success "Homebrew installed"
    return 0
  }
  step "Install Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv 2> /dev/null || /usr/local/bin/brew shellenv)"
  success "Homebrew installed"
}

ensure_chezmoi() {
  command -v chezmoi > /dev/null && {
    success "chezmoi installed"
    return 0
  }
  step "Install chezmoi"
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
  success "chezmoi installed"
}

# Repository management
clone_or_update_repo() {
  step "Sync dotfiles repository"
  dir="$HOME/.local/share/chezmoi"
  url="https://github.com/mariomarin/dotfiles.git"
  mkdir -p "$dir"
  git -C "$dir" init -q
  git -C "$dir" remote set-url origin "$url" 2> /dev/null || git -C "$dir" remote add origin "$url"
  git -C "$dir" fetch -q origin main
  if git -C "$dir" rev-parse -q --verify HEAD > /dev/null; then
    git -C "$dir" merge -q --ff-only origin/main || printf "⚠️  Local changes, skipped fast-forward\n" >&2
  else
    git -C "$dir" checkout -q -B main --track origin/main
  fi
  success "Repository ready"
}

# Chezmoi operations
init_and_apply() {
  step "Initialize chezmoi"
  chezmoi init --force
  step "Apply dotfiles"
  chezmoi apply -v
  success "Dotfiles applied"
}

# Nix-based setup (requires Bitwarden)
setup_nix_env() {
  step "Setup with nix-shell"
  # shellcheck disable=SC2016
  nix-shell .install/shell.nix --run '
        set -eu
        printf "\n==> Setup Bitwarden\n"
        bw login --check >/dev/null 2>&1 || bw login
        just bw-unlock
        printf "\n==> Initialize chezmoi\n"
        chezmoi init --force
    '
}

# Bootstrap flows
bootstrap_linux_apt() {
  export PATH="$HOME/.local/bin:$PATH"
  ensure_chezmoi && init_and_apply
  printf "\n✅ Bootstrap complete! Future updates: chezmoi apply\n"
}

bootstrap_darwin() {
  ensure_nix && ensure_homebrew && setup_nix_env
  # shellcheck disable=SC2016
  nix-shell .install/shell.nix --run 'cd nix/darwin && just first-time'
  printf "\n✅ Bootstrap complete! Future updates: just darwin\n"
}

bootstrap_nixos() {
  is_nixos || error "NixOS required"
  setup_nix_env
  # shellcheck disable=SC2016
  nix-shell .install/shell.nix --run 'cd nix/nixos && just first-time'
  printf "\n✅ Bootstrap complete! Future updates: just nixos\n"
}

# Main
main() {
  printf "🚀 Dotfiles Bootstrap\n\n" >&2

  PLATFORM=$(detect_platform)
  printf "Detected: %s\n" "$PLATFORM" >&2

  [ -z "${HOSTNAME:-}" ] && HOSTNAME=$(hostname -s)
  export HOSTNAME
  printf "Hostname: %s\n\n" "$HOSTNAME" >&2

  clone_or_update_repo
  cd "$HOME/.local/share/chezmoi"

  case "$PLATFORM" in
    linux-apt) bootstrap_linux_apt ;;
    darwin) bootstrap_darwin ;;
    nixos) bootstrap_nixos ;;
  esac
}

main

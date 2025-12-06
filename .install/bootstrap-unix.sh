#!/bin/sh
# Bootstrap script for Unix-like systems (macOS, Linux)
# Run via: curl -sfL https://raw.githubusercontent.com/mariomarin/dotfiles/main/.install/bootstrap-unix.sh | sh

set -eu

# Helper functions
error() {
  _msg="$1"
  shift
  printf "\n❌ %s\n" "$_msg" >&2
  for _line in "$@"; do
    printf "   %s\n" "$_line" >&2
  done
  printf "\n" >&2
  exit 1
}

info() { printf "ℹ️  %s\n" "$1" >&2; }
success() { printf "✅ %s\n" "$1" >&2; }
step() { printf "\n==> %s\n" "$1" >&2; }

# Main bootstrap
printf "🚀 Dotfiles Bootstrap for Unix\n\n" >&2

case "$(uname -s)" in
  Darwin)
    step "Install Nix"
    if ! command -v nix > /dev/null 2>&1; then
      printf "Installing Nix package manager...\n"
      curl -sfL https://install.determinate.systems/nix | sh -s -- install

      # Source nix profile to make nix available in current shell
      if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        # shellcheck source=/dev/null
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      fi

      success "Nix installed"
    else
      success "Nix already installed"
    fi

    step "Install Homebrew"
    if command -v brew > /dev/null 2>&1; then
      success "Homebrew already installed"
    else
      printf "Installing Homebrew...\n"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      success "Homebrew installed"
    fi
    ;;

  Linux)
    step "Verify NixOS"
    if [ ! -f /etc/os-release ] || ! grep -q "ID=nixos" /etc/os-release; then
      error "This configuration only supports NixOS on Linux" \
        "For other distributions, use NixOS or WSL with NixOS"
    fi
    success "NixOS detected"
    ;;

  *)
    error "Unsupported OS: $(uname -s)"
    ;;
esac

# Clone repository if needed
step "Clone dotfiles repository"
if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
  info "Repository already exists"
else
  git clone https://github.com/mariomarin/dotfiles.git "$HOME/.local/share/chezmoi"
  success "Repository cloned"
fi

# Enter nix-shell and run remaining setup
step "Enter nix-shell environment"
cd "$HOME/.local/share/chezmoi"
# shellcheck disable=SC2016
nix-shell .install/shell.nix --run '
  set -eu

  printf "\n==> Setup Bitwarden\n"
  if ! bw login --check >/dev/null 2>&1; then
    printf "⚠️  Please login to Bitwarden:\n"
    bw login
  fi

  printf "Unlocking vault...\n"
  just bw-unlock

  printf "\n==> Initialize chezmoi\n"

  # Check if HOSTNAME is set
  if [ -z "${HOSTNAME:-}" ]; then
    printf "Available machines:\n"
    yq ".machines | keys | .[]" .chezmoidata/machines.yaml
    printf "\nEnter hostname for this machine: "
    read -r HOSTNAME
    export HOSTNAME
  fi

  printf "✅ Using hostname: %s\n" "$HOSTNAME"
  chezmoi init --force

  printf "\n==> Apply system configuration\n"
  case "$(uname -s)" in
    Darwin)
      printf "Applying nix-darwin configuration...\n"
      cd nix/darwin && just first-time
      ;;
    Linux)
      printf "Applying NixOS configuration...\n"
      cd nix/nixos && just first-time
      ;;
  esac

  printf "\n✅ Bootstrap complete!\n"
  printf "\nYour system is now configured!\n"
  printf "\nFuture updates:\n"
  printf "  macOS:  cd ~/.local/share/chezmoi && just darwin\n"
  printf "  NixOS:  cd ~/.local/share/chezmoi && just nixos\n"
'

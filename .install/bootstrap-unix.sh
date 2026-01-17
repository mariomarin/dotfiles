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
is_chef_managed() { [ -d /opt/chef ] || command -v chef-client > /dev/null 2>&1; }
is_nixos() { grep -q "ID=nixos" /etc/os-release 2> /dev/null; }
is_darwin() { [ "$(uname -s)" = "Darwin" ]; }

# Auto-detect platform from environment
detect_platform() {
    if is_darwin; then
        is_chef_managed && echo "darwin-brew" || echo "darwin"
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
    success "Homebrew installed"
}

ensure_chezmoi() {
    command -v chezmoi > /dev/null && {
                                       success "chezmoi found"
                                                                return 0
  }
    error "chezmoi not found - install via package manager"
}

ensure_nixos() {
    is_nixos && {
                  success "NixOS detected"
                                            return 0
  }
    error "NixOS required"
}

# Repository management
clone_or_update_repo() {
    step "Clone dotfiles repository"
    [ -d "$HOME/.local/share/chezmoi/.git" ] && {
        git -C "$HOME/.local/share/chezmoi" pull --ff-only 2> /dev/null || true
        success "Repository updated"
        return 0
  }
    git clone https://github.com/mariomarin/dotfiles.git "$HOME/.local/share/chezmoi"
    success "Repository cloned"
}

# Chezmoi operations
init_chezmoi() {
    step "Initialize chezmoi"
    chezmoi init --force
    success "Initialized for $HOSTNAME"
}

apply_chezmoi() {
    step "Apply dotfiles"
    chezmoi apply -v
    success "Dotfiles applied"
}

# Platform-specific setup
setup_nix_shell() {
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

apply_darwin() {
    # shellcheck disable=SC2016
    nix-shell .install/shell.nix --run 'cd nix/darwin && just first-time'
    printf "\n✅ Bootstrap complete! Future updates: just darwin\n"
}

apply_nixos() {
    # shellcheck disable=SC2016
    nix-shell .install/shell.nix --run 'cd nix/nixos && just first-time'
    printf "\n✅ Bootstrap complete! Future updates: just nixos\n"
}

apply_chef_managed() {
    init_chezmoi
    apply_chezmoi
    printf "\n✅ Bootstrap complete! Future updates: chezmoi apply\n"
}

# Bootstrap flows per platform
bootstrap_chef()   { ensure_chezmoi && apply_chef_managed; }
bootstrap_darwin() { ensure_nix && ensure_homebrew && setup_nix_shell && apply_darwin; }
bootstrap_nixos()  { ensure_nixos && setup_nix_shell && apply_nixos; }

# Main
main() {
    printf "🚀 Dotfiles Bootstrap\n\n" >&2

    PLATFORM=$(detect_platform)
    printf "Detected platform: %s\n" "$PLATFORM" >&2

    # Get hostname if not set
    [ -z "${HOSTNAME:-}" ] && HOSTNAME=$(hostname -s)
    export HOSTNAME
    printf "Hostname: %s\n\n" "$HOSTNAME" >&2

    clone_or_update_repo
    cd "$HOME/.local/share/chezmoi"

    case "$PLATFORM" in
        darwin-brew | linux-apt) bootstrap_chef ;;
        darwin)                bootstrap_darwin ;;
        nixos)                 bootstrap_nixos ;;
  esac
}

main

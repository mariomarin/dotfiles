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

# Platform detection
# - Darwin + chef → darwin-brew (no nix)
# - Darwin + no chef → darwin (nix-darwin)
# - Linux + NixOS → nixos
# - Linux + other → linux-apt (apt/WSL/codespaces)
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

ensure_nushell() {
    command -v nu > /dev/null && {
        success "Nushell installed"
        return 0
  }
    step "Install Nushell from Gemfury"
    KEY_FILE="/etc/apt/keyrings/fury-nushell.gpg"
    if [ ! -f "$KEY_FILE" ]; then
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://apt.fury.io/nushell/gpg.key | sudo gpg --dearmor -o "$KEY_FILE"
        echo "deb [signed-by=$KEY_FILE] https://apt.fury.io/nushell/ /" |
            sudo tee /etc/apt/sources.list.d/nushell.list > /dev/null
        sudo apt-get update -qq
  fi
    sudo apt-get install -y -qq nushell
    success "Nushell installed"
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
    ensure_nushell && ensure_chezmoi && init_and_apply
    printf "\n✅ Bootstrap complete! Future updates: chezmoi apply\n"
}

bootstrap_darwin_brew() {
    ensure_homebrew && ensure_chezmoi && init_and_apply
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
        linux-apt)    bootstrap_linux_apt ;;
        darwin-brew)  bootstrap_darwin_brew ;;
        darwin)       bootstrap_darwin ;;
        nixos)        bootstrap_nixos ;;
  esac
}

main

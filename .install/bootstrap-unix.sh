#!/bin/sh
# Bootstrap script for Unix-like systems
# Usage: curl -sfL .../bootstrap-unix.sh | HOSTNAME=ribosome sh
set -eu

# Output helpers
error() {
          printf "\n❌ %s\n" "$1" >&2
                                        exit 1
}
success() { printf "✅ %s\n" "$1" >&2; }
step() { printf "\n==> %s\n" "$1" >&2; }

# Platform detection
get_platform() {
    case "$1" in
        axon)                          echo "darwin-brew" ;;
        ribosome)                      echo "linux-apt" ;;
        malus)                         echo "darwin" ;;
        dendrite | symbiont | mitosis) echo "nixos" ;;
        *)                             echo "unknown" ;;
  esac
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
    error "chezmoi not found - install via Chef"
}

ensure_nixos() {
    grep -q "ID=nixos" /etc/os-release 2> /dev/null && {
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

# Chezmoi initialization
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
bootstrap_darwin_brew() { ensure_chezmoi && apply_chef_managed; }
bootstrap_linux_apt()   { ensure_chezmoi && apply_chef_managed; }
bootstrap_darwin()      { ensure_nix && ensure_homebrew && setup_nix_shell && apply_darwin; }
bootstrap_nixos()       { ensure_nixos && setup_nix_shell && apply_nixos; }

# Main
main() {
    printf "🚀 Dotfiles Bootstrap\n\n" >&2

    [ -z "${HOSTNAME:-}" ] && {
        printf "Available: malus, dendrite, symbiont, mitosis, axon, ribosome\n"
        printf "Enter hostname: " && read -r HOSTNAME
  }
    export HOSTNAME

    PLATFORM=$(get_platform "$HOSTNAME")
    printf "Platform: %s (%s)\n" "$HOSTNAME" "$PLATFORM" >&2

    clone_or_update_repo
    cd "$HOME/.local/share/chezmoi"

    case "$PLATFORM" in
        darwin-brew) bootstrap_darwin_brew ;;
        linux-apt)   bootstrap_linux_apt ;;
        darwin)      bootstrap_darwin ;;
        nixos)       bootstrap_nixos ;;
        *)           error "Unknown platform: $HOSTNAME" ;;
  esac
}

main

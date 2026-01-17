#!/bin/sh
# Bootstrap script for Unix-like systems (macOS, Linux)
# Usage: curl -sfL .../bootstrap-unix.sh | sh
#        curl -sfL .../bootstrap-unix.sh | HOSTNAME=ribosome sh

set -eu

error() {
    printf "\n❌ %s\n" "$1" >&2
    shift
    for line in "$@"; do printf "   %s\n" "$line" >&2; done
    exit 1
}
success() { printf "✅ %s\n" "$1" >&2; }
step() { printf "\n==> %s\n" "$1" >&2; }

# Detect platform from hostname
get_platform() {
    case "$1" in
        axon)     echo "darwin-brew" ;;
        ribosome) echo "linux-apt" ;;
        malus)    echo "darwin" ;;
        dendrite | symbiont | mitosis) echo "nixos" ;;
        *) echo "unknown" ;;
  esac
}

printf "🚀 Dotfiles Bootstrap\n\n" >&2

# Get or prompt for hostname
if [ -z "${HOSTNAME:-}" ]; then
    printf "Available machines: malus, dendrite, symbiont, mitosis, axon, ribosome\n"
    printf "Enter hostname for this machine: "
    read -r HOSTNAME
fi
export HOSTNAME

PLATFORM=$(get_platform "$HOSTNAME")
printf "Platform: %s (%s)\n\n" "$HOSTNAME" "$PLATFORM" >&2

# Clone repository
step "Clone dotfiles repository"
if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
    git -C "$HOME/.local/share/chezmoi" pull --ff-only 2> /dev/null || true
    success "Repository updated"
else
    git clone https://github.com/mariomarin/dotfiles.git "$HOME/.local/share/chezmoi"
    success "Repository cloned"
fi

cd "$HOME/.local/share/chezmoi"

# Platform-specific bootstrap
case "$PLATFORM" in
    darwin-brew | linux-apt)
        # Chef-managed: no Nix, no Bitwarden
        step "Verify chezmoi"
        command -v chezmoi > /dev/null 2>&1 || error "chezmoi not found - install via Chef"
        success "chezmoi found"

        step "Initialize chezmoi"
        chezmoi init --force
        success "Initialized for $HOSTNAME"

        step "Apply dotfiles"
        chezmoi apply -v
        success "Dotfiles applied"

        printf "\n✅ Bootstrap complete!\n"
        printf "Future updates: chezmoi apply\n"
        ;;

    darwin)
        step "Install Nix"
        if ! command -v nix > /dev/null 2>&1; then
            curl -sfL https://install.determinate.systems/nix | sh -s -- install
            # shellcheck source=/dev/null
            [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] &&
                . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
            success "Nix installed"
    else
            success "Nix already installed"
    fi

        step "Install Homebrew"
        if ! command -v brew > /dev/null 2>&1; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            success "Homebrew installed"
    else
            success "Homebrew already installed"
    fi

        step "Setup with nix-shell"
        # shellcheck disable=SC2016
        nix-shell .install/shell.nix --run '
            set -eu
            printf "\n==> Setup Bitwarden\n"
            bw login --check >/dev/null 2>&1 || bw login
            just bw-unlock

            printf "\n==> Initialize chezmoi\n"
            chezmoi init --force

            printf "\n==> Apply nix-darwin\n"
            cd nix/darwin && just first-time

            printf "\n✅ Bootstrap complete!\n"
            printf "Future updates: just darwin\n"
        '
        ;;

    nixos)
        step "Verify NixOS"
        grep -q "ID=nixos" /etc/os-release 2> /dev/null ||
            error "NixOS required" "Use NixOS or WSL with NixOS"
        success "NixOS detected"

        step "Setup with nix-shell"
        # shellcheck disable=SC2016
        nix-shell .install/shell.nix --run '
            set -eu
            printf "\n==> Setup Bitwarden\n"
            bw login --check >/dev/null 2>&1 || bw login
            just bw-unlock

            printf "\n==> Initialize chezmoi\n"
            chezmoi init --force

            printf "\n==> Apply NixOS\n"
            cd nix/nixos && just first-time

            printf "\n✅ Bootstrap complete!\n"
            printf "Future updates: just nixos\n"
        '
        ;;

    *)
        error "Unknown platform for hostname: $HOSTNAME"
        ;;
esac

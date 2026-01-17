#!/bin/sh
# Bootstrap for chef-managed hosts (no Bitwarden, no Nix)
# Run via: curl -sfL https://raw.githubusercontent.com/mariomarin/dotfiles/main/.install/bootstrap-chef.sh | HOSTNAME=ribosome sh

set -eu

error() {
          printf "\n❌ %s\n" "$1" >&2
                                        exit 1
}
success() { printf "✅ %s\n" "$1" >&2; }
step() { printf "\n==> %s\n" "$1" >&2; }

printf "🚀 Dotfiles Bootstrap (Chef-managed)\n\n" >&2

[ -z "${HOSTNAME:-}" ] && error "HOSTNAME must be set (e.g., HOSTNAME=ribosome)"

step "Verify chezmoi is installed"
command -v chezmoi > /dev/null 2>&1 || error "chezmoi not found - install via Chef or manually"
success "chezmoi found"

step "Clone dotfiles repository"
if [ -d "$HOME/.local/share/chezmoi/.git" ]; then
  printf "Repository exists, pulling latest...\n"
  git -C "$HOME/.local/share/chezmoi" pull --ff-only
else
  git clone https://github.com/mariomarin/dotfiles.git "$HOME/.local/share/chezmoi"
fi
success "Repository ready"

step "Initialize chezmoi"
export HOSTNAME
chezmoi init --force
success "chezmoi initialized for $HOSTNAME"

step "Apply dotfiles"
chezmoi apply -v
success "Dotfiles applied"

printf "\n✅ Bootstrap complete!\n"
printf "\nFuture updates: chezmoi apply\n"

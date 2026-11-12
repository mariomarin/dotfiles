#!/bin/sh
# Dotfiles hook for Codespaces/devcontainers: user-level chezmoi apply, no Nix or root
set -eu

src="$(cd "$(dirname "$0")" && pwd)"
export PATH="$HOME/.local/bin:$PATH"

command -v chezmoi > /dev/null || sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
chezmoi init --apply --source "$src"

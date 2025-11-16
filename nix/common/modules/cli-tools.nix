# Shared CLI tools for both NixOS and nix-darwin
# This module provides essential CLI utilities that work identically on both platforms
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Shell and terminal
    zsh
    nushell # Cross-platform shell for justfile scripting
    tmux
    alacritty # Terminal emulator (GUI but works on both)

    # Editor
    neovim

    # Version control
    git
    git-lfs
    gh # GitHub CLI
    git-branchless

    # File management
    rsync
    tree

    # Search and text processing
    fzf
    ripgrep
    fd
    sd
    jq
    yq-go

    # Network utilities
    curl
    wget

    # Modern CLI replacements
    bat # Better cat
    eza # Better ls
    delta # Better git diff
    zoxide # Better cd

    # Development tools
    just # Command runner
    direnv # Environment management

    # System utilities
    htop
    bottom # Better top
    dua # Disk usage analyzer
    procs # Better ps

    # Password management
    bitwarden-cli
    age # Encryption

    # Misc
    topgrade # Universal package updater
    atuin # Shell history sync
  ];

  # Shell configuration (works on both platforms)
  programs.zsh.enable = true;

  # Direnv for per-project environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}

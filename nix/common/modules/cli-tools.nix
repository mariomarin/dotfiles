# Shared CLI tools for both NixOS and nix-darwin
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Shell and terminal
    zsh
    nushell
    tmux
    alacritty

    # Editor
    neovim

    # Version control
    git
    git-lfs
    gh
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
    bat
    eza
    delta
    zoxide

    # Development tools
    just
    direnv

    # System utilities
    htop
    bottom
    dua
    procs

    # Password management
    bitwarden-cli
    age

    # Misc
    topgrade
    atuin
  ];

  programs.zsh.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}

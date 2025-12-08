# Shared development tools for both NixOS and nix-darwin
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Dotfiles and environment
    unstable.chezmoi
    direnv

    # AI assistant
    claude-code

    # Nix development
    niv
    nix-direnv
    nil
    unstable.devenv

    # Editors
    unstable.neovim

    # Go
    go
    gopls
    gotools
    go-tools
    golangci-lint

    # Python
    python3
    python3Packages.pip
    python3Packages.virtualenv
    poetry
    ruff
    pyright

    # Rust
    rustup
    rust-analyzer

    # Lua
    lua5_1
    luarocks

    # Node.js
    nodejs_22
    nodePackages.yarn

    # Java
    openjdk

    # Build tools
    bear
    clang
    gnumake
    cmake
    pkg-config

    # Containers
    docker-compose
    dive
    lazydocker

    # Databases
    postgresql
    sqlite

    # API testing
    httpie
    curlie

    # Infrastructure as Code
    terraform
    ansible

    # Documentation
    pandoc
    plantuml

    # Utilities
    unstable.svu
    unstable.tree-sitter
  ];
}

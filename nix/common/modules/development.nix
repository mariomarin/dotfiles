# Shared development tools for both NixOS and nix-darwin
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Go development
    go
    gopls
    gotools
    go-tools
    golangci-lint

    # Python development
    python3
    python3Packages.pip
    python3Packages.virtualenv
    ruff
    pyright

    # Rust development
    rustup
    rust-analyzer

    # Node.js development
    nodejs_22
    nodePackages.pnpm
    nodePackages.yarn

    # Build tools
    gnumake
    cmake
    pkg-config

    # Container tools
    docker-compose
    dive
    lazydocker

    # Database clients
    postgresql
    sqlite

    # API testing
    httpie
    curlie

    # Infrastructure as Code
    terraform
    ansible
  ];
}

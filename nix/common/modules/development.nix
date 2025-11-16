# Shared development tools for both NixOS and nix-darwin
# Language toolchains, compilers, and build tools
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Go development
    go
    gopls # Go language server
    gotools
    go-tools # staticcheck, etc.
    golangci-lint

    # Python development
    python3
    python3Packages.pip
    python3Packages.virtualenv
    ruff # Fast Python linter
    pyright # Python language server

    # Rust development
    rustup # Rust toolchain manager
    rust-analyzer # Rust language server

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
    dive # Docker image explorer
    lazydocker # Docker TUI

    # Database clients
    postgresql # Includes psql
    sqlite

    # API testing
    httpie
    curlie # Better curl with httpie syntax

    # Infrastructure as Code
    terraform
    ansible

    # Cloud CLIs (optional, can be per-project)
    # awscli2
    # google-cloud-sdk
  ];

  # Docker/Podman - platform-specific configuration
  # NixOS: virtualisation.docker.enable = true
  # Darwin: Use Docker Desktop or colima
}

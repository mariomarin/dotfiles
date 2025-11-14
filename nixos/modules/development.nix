# Development tools module
# Provides languages, build tools, and development environment for coding workstations
{ config, pkgs, lib, ... }:

let
  cfg = config.custom.development;
in
{
  options.custom.development = {
    enable = lib.mkEnableOption "development tools and environment";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Dotfiles and environment management
      unstable.chezmoi  # Dotfiles manager (latest version from unstable)
      direnv            # Environment switcher for the shell

      # Nix development tools
      niv               # Dependency management for Nix
      nix-direnv        # Integration of direnv with Nix

      # Development environment
      unstable.devenv   # Fast, declarative, reproducible development environments
      unstable.neovim   # Hyperextensible Vim-based text editor

      # Version utilities
      unstable.svu      # Semantic Version Util v3.x

      # AI assistant
      claude-code       # Claude AI coding assistant CLI

      # Languages & runtimes
      go              # Go programming language
      gopls           # Go language server
      lua5_1          # Lua 5.1 interpreter
      luarocks        # Package manager for Lua
      nodejs          # JavaScript runtime
      openjdk         # Open Java Development Kit
      rustup          # Rust toolchain installer

      # Build tools & compilers
      bear            # Build EAR - tool for generating compilation database
      clang           # C language family frontend for LLVM
      gnumake         # GNU Make build automation tool
      pkg-config      # Helper tool for compiling applications and libraries

      # Development utilities
      dive            # Docker image explorer and layer analyzer
      nil             # Nix language server
      pandoc          # Universal markup converter
      plantuml        # Tool to generate UML diagrams from text
      poetry          # Python dependency management and packaging
      sqlite          # SQL database engine
      unstable.tree-sitter # Parser generator and incremental parsing library
      zeal            # Offline documentation browser
    ];
  };
}

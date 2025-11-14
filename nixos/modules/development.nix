# Development tools module
# Provides Nix tooling and development environment tools
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
      # Nix development tools
      niv          # Dependency management for Nix
      nix-direnv   # Integration of direnv with Nix

      # Development environment
      unstable.devenv   # Fast, declarative, reproducible development environments
      unstable.neovim   # Hyperextensible Vim-based text editor

      # Version utilities
      unstable.svu      # Semantic Version Util v3.x

      # AI assistant
      claude-code       # Claude AI coding assistant CLI
    ];
  };
}

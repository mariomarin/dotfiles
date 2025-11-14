# Minimal system packages module
# Provides essential CLI tools for server/headless environments
{ config, pkgs, lib, ... }:

let
  cfg = config.custom.minimal;
in
{
  options.custom.minimal = {
    enable = lib.mkEnableOption "minimal system packages";

    modernCli = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include modern CLI replacements (bat, eza, ripgrep, etc.)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Minimal system packages for headless environments
    # Per-project tools should come from devenv.nix
    environment.systemPackages = with pkgs; [
      # Essential tools
      vim
      git
      tmux
      sesh      # Smart session manager for tmux
      upterm    # Secure terminal sharing
      viddy     # Modern watch command with diff highlighting
      bash      # Bourne Again Shell

      # File utilities
      file      # Determine file types
      unzip     # Extract compressed files

      # Network utilities
      wget
      curl
      rsync

      # System monitoring
      htop

      # Data processing
      jq
      yq-go

      # Development utilities
      age       # Encryption tool (for chezmoi)
      fzf       # Command-line fuzzy finder
      gh        # GitHub CLI tool
      just      # Command runner similar to make
    ] ++ lib.optionals cfg.modernCli [
      # Modern CLI replacements
      bat       # cat with syntax highlighting
      eza       # modern ls
      ripgrep   # modern grep
      fd        # modern find
      bottom    # modern top/htop
      delta     # modern diff
      lazygit   # TUI for git
    ];
  };
}

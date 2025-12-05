# Minimal system packages module
# Essential CLI tools and utilities for all hosts
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
      gitFull # Git version control system with all features
      tmux
      sesh # Smart session manager for tmux
      cloudflared # Cloudflare Tunnel for secure access without exposing ports
      viddy # Modern watch command with diff highlighting
      bash # Bourne Again Shell
      nushell # Modern shell with structured data support (used by chezmoi scripts)
      oh-my-posh # Prompt framework for nushell and other shells
      python3 # Python 3 interpreter (required by tmux extrakto plugin)

      # File utilities
      file # Determine file types
      unzip # Extract compressed files

      # Network utilities
      wget
      curl
      rsync

      # System monitoring
      htop

      # Data processing
      jq
      yq-go
      miller # Like awk, sed, cut, join for CSV, TSV, and JSON

      # Development utilities
      age # Encryption tool (for chezmoi)
      fzf # Command-line fuzzy finder
      gh # GitHub CLI tool
      just # Command runner similar to make

      # System utilities
      atuin # Shell history sync, search and backup
      bitwarden-cli # Password manager CLI
      cf-vault # Cloudflare credentials management (uses system keyring)
      cheat # Create and view interactive cheatsheets
      envsubst # Substitutes environment variables in shell format strings
      libnotify # Desktop notification library
      libzip # Library for reading, creating, and modifying zip archives
      navi # Interactive cheatsheet tool
      pay-respects # Press F to pay respects in the terminal
      speedtest-cli # Internet bandwidth speed test
      tealdeer # Fast tldr client in Rust
      topgrade # Upgrade all the things (system packages, plugins, etc.)
      trippy # Network diagnostic tool combining traceroute and ping
    ] ++ lib.optionals cfg.modernCli [
      # Modern CLI replacements
      bat # cat with syntax highlighting
      bottom # modern top/htop
      delta # modern diff
      difftastic # structural diff tool that understands syntax
      dua # disk usage analyzer (alternative to du)
      eza # modern ls
      fd # modern find
      lazygit # TUI for git
      lfs # list file system info (modern lsfd)
      lsd # modern ls with colors and icons
      pipr # interactive pipe evaluation tool
      procs # modern replacement for ps
      pstree # show the set of running processes as a tree
      ripgrep # modern grep
      sd # modern replacement for sed
      xcp # modern replacement for cp with progress
      zoxide # modern replacement for cd with frecency
    ];
  };
}

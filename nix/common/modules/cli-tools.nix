# Shared CLI tools for both NixOS and nix-darwin
# Provides essential command-line utilities with optional modern replacements
{ config, pkgs, lib, ... }:

let
  cfg = config.custom.cli;
in
{
  options.custom.cli = {
    enable = lib.mkEnableOption "CLI tools";

    modernCli = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include modern CLI replacements (bat, eza, ripgrep, etc.)";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # ── Shells ──────────────────────────────────────────────────────────
      zsh
      bash
      nushell
      oh-my-posh # Prompt framework
      carapace # Universal completion framework

      # ── Terminal multiplexer ────────────────────────────────────────────
      tmux
      zellij # Modern terminal multiplexer (Rust)
      sesh # Smart session manager for tmux
      zesh # Smart session manager for zellij (custom pkg)

      # ── Editor ──────────────────────────────────────────────────────────
      vim
      neovim

      # ── Version control ─────────────────────────────────────────────────
      git
      git-lfs
      gh # GitHub CLI
      bitbucket-cli # Bitbucket CLI (custom pkg)
      git-branchless
      lazygit # TUI for git

      # ── File management ─────────────────────────────────────────────────
      file # Determine file types
      tree
      rsync
      unzip

      # ── Search and text processing ──────────────────────────────────────
      fzf
      jq
      yq-go
      miller # CSV, TSV, JSON processing

      # ── Network utilities ───────────────────────────────────────────────
      curl
      wget
      cloudflared # Cloudflare Tunnel client
      speedtest-cli # Internet speed test
      trippy # Network diagnostic (traceroute + ping)

      # ── System monitoring ───────────────────────────────────────────────
      htop
      viddy # Modern watch command

      # ── Development tools ───────────────────────────────────────────────
      just # Command runner
      direnv
      age # Encryption (for chezmoi)

      # ── Kubernetes ──────────────────────────────────────────────────────
      kubectl
      krew
      kubelogin

      # ── Password and secrets ────────────────────────────────────────────
      bitwarden-cli

      # ── Shell utilities ─────────────────────────────────────────────────
      atuin # Shell history sync and search
      pay-respects # Terminal command correction
      topgrade # Update everything
      envsubst # Environment variable substitution

      # ── Help and documentation ──────────────────────────────────────────
      cheat # Interactive cheatsheets
      navi # Interactive cheatsheet tool
      tealdeer # Fast tldr client

      # ── Nushell plugins ─────────────────────────────────────────────────
      nushellPlugins.formats # EML, ICS, INI, plist, VCF support
      nushellPlugins.query # Query JSON, XML, web data
      nushellPlugins.gstat # Git status as structured data

      # ── Libraries ──────────────────────────────────────────────────────
      libzip # Zip archive library
    ] ++ lib.optionals cfg.modernCli [
      # ── Modern CLI replacements ─────────────────────────────────────────
      bat # cat with syntax highlighting
      bottom # Modern top/htop
      delta # Modern diff
      difftastic # Structural diff
      dua # Disk usage analyzer
      eza # Modern ls
      fd # Modern find
      lsd # Modern ls with icons
      procs # Modern ps
      pstree # Process tree
      ripgrep # Modern grep
      sd # Modern sed
      xcp # Modern cp with progress
      zoxide # Modern cd with frecency
    ];

    programs.zsh.enable = true;

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}

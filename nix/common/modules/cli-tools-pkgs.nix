# Package lists for CLI tools — shared between cli-tools.nix (NixOS/darwin) and
# the ribosome-env bundle (linux-apt). Returns { base, modern } lists.
pkgs: {
  base = with pkgs; [
    # ── Shells ──────────────────────────────────────────────────────────
    zsh
    bash
    nushell
    oh-my-posh # Prompt framework
    carapace # Universal completion framework

    # ── Terminal multiplexer ────────────────────────────────────────────
    tmux
    sesh # Smart session manager for tmux
    clipper # Clipboard over SSH

    # ── Editor ──────────────────────────────────────────────────────────
    vim
    neovim

    # ── Version control ─────────────────────────────────────────────────
    git
    git-lfs
    gh # GitHub CLI
    gh-dash # GitHub PR dashboard TUI
    bitbucket-cli # Bitbucket CLI (custom pkg)
    unstable.jujutsu # Modern VCS (jj command)
    jj-spr # Stacked PRs for jj (write access repos)
    jj-stack # Stacked PRs for jj (read-only repos)
    jj-hooks # Hook runner for jj pushes (jj-hp)
    lazygit # TUI for git

    # ── File management ─────────────────────────────────────────────────
    file # Determine file types
    tree
    rsync
    unzip

    # ── Search and text processing ──────────────────────────────────────
    fzf
    jq
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
    chezmoi
    age # Encryption (for chezmoi)
    kubectl

    # ── Password and secrets ────────────────────────────────────────────
    bitwarden-cli

    # ── Shell utilities ─────────────────────────────────────────────────
    unstable.atuin # Shell history sync and search
    pay-respects # Terminal command correction
    topgrade # Update everything
    envsubst # Environment variable substitution

    # ── Help and documentation ──────────────────────────────────────────
    cheat # Interactive cheatsheets
    navi # Interactive cheatsheet tool
    tealdeer # Fast tldr client
    presenterm # Terminal slideshow presentations

    # ── Nushell plugins ─────────────────────────────────────────────────
    nushellPlugins.formats # EML, ICS, INI, plist, VCF support
    nushellPlugins.query # Query JSON, XML, web data
    nushellPlugins.gstat # Git status as structured data

    # ── Libraries ──────────────────────────────────────────────────────
    libzip # Zip archive library
  ];

  modern = with pkgs; [
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
}

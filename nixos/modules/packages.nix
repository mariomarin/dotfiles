{ config, pkgs, lib, ... }:

{
  # Package overrides - for flakes these will be handled differently
  # Keeping NUR for now, but unstable channel will be replaced by flake input
  nixpkgs.config.packageOverrides = pkgs: {
    # unstable = import <nixos-unstable> { config = config.nixpkgs.config; };
    nur = import
      (builtins.fetchTarball
        "https://github.com/nix-community/NUR/archive/master.tar.gz"
      )
      {
        inherit pkgs;
      };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # Desktop Applications
    alacritty # GPU-accelerated terminal emulator
    baobab # Disk usage analyzer with graphical interface
    brave # Privacy-focused web browser
    copyq # Clipboard Manager with Advanced Features
    firefox # Open-source web browser
    gimp # GNU Image Manipulation Program
    gnome-disk-utility # Disk management utility
    transmission_3 # BitTorrent client
    zathura # PDF/document viewer
    zoom-us # Video conferencing software

    # Terminal Tools & Utilities
    age # Simple, modern encryption tool (for chezmoi)
    atuin # Shell history sync, search and backup
    bash # Bourne Again Shell
    unstable.chezmoi # Dotfiles manager (latest version from unstable)
    curl # Command line tool for transferring data with URLs
    direnv # Environment switcher for the shell
    envsubst # Substitutes environment variables in shell format strings
    file # Determine file types
    fuse # Filesystem in Userspace
    fzf # Command-line fuzzy finder
    gh # GitHub CLI tool
    gitFull # Git version control system with all features
    hledger # Plain text accounting
    lazygit # Terminal UI for git
    jq # Command-line JSON processor
    just # Command runner similar to make
    libnotify # Desktop notification library
    libzip # Library for reading, creating, and modifying zip archives
    miller # Like awk, sed, cut, join for CSV, TSV, and JSON
    pay-respects # Press F to pay respects in the terminal
    speechd # Common interface to speech synthesis
    tmux # Terminal multiplexer
    topgrade # Upgrade all the things (system packages, plugins, etc.)
    unzip # Extract compressed files in ZIP format
    upterm # Secure terminal sharing
    viddy # Modern watch command with diff highlighting
    yq-go # Command-line YAML processor

    # Modern CLI Replacements
    bat # Modern replacement for cat with syntax highlighting
    bottom # Modern replacement for htop/top
    delta # Modern replacement for diff with syntax highlighting
    difftastic # Structural diff tool that understands syntax
    dua # Disk usage analyzer (alternative to du)
    eza # Modern replacement for ls
    fd # Modern replacement for find
    lfs # List file system info (modern lsfd)
    lsd # Modern ls with colors and icons
    pipr # Interactive pipe evaluation tool
    procs # Modern replacement for ps
    ripgrep # Modern replacement for grep (faster)
    sd # Modern replacement for sed
    xcp # Modern replacement for cp with progress
    zoxide # Modern replacement for cd with frecency

    # Documentation & Help
    cheat # Create and view interactive cheatsheets
    navi # Interactive cheatsheet tool
    tealdeer # Fast tldr client in Rust

    # Security & Authentication
    bitwarden # Password manager
    credstash # Credential management using AWS KMS
    gnupg # GNU Privacy Guard
    keychain # Re-use SSH and GPG agents between logins
    libsecret # Library for storing and retrieving passwords
    openssl # Cryptography and SSL/TLS toolkit
    openssl.dev # OpenSSL development files

    # Cloud & Networking
    aws-sso-cli # AWS SSO credential helper
    awscli2 # Amazon Web Services CLI v2
    kubectl # Kubernetes command-line tool
    krew # Plugin manager for kubectl
    nss # Network Security Services
    nssTools # NSS security tools
    ntfs3g # NTFS filesystem driver
    rclone # Cloud storage sync utility
    speedtest-cli # Internet bandwidth speed test
    stern # Multi-pod and container log tailing for Kubernetes
    syncthing # Continuous file synchronization
    sysdig # System exploration and troubleshooting tool
    trippy # Network diagnostic tool combining traceroute and ping

    # Development Tools
    bear # Build EAR - tool for generating compilation database
    bun # Fast JavaScript runtime and package manager
    clang # C language family frontend for LLVM
    devbox # Instant, portable dev environments
    dive # Docker image explorer and layer analyzer
    git-branchless # High-velocity, monorepo-scale workflow for Git
    gnumake # GNU Make build automation tool
    go # Go programming language
    gopls # Go language server
    luarocks # Package manager for Lua
    meilisearch # Fast, open-source search engine
    nil # Nix language server
    openjdk # Open Java Development Kit
    pkg-config # Helper tool for compiling applications and libraries
    plantuml # Tool to generate UML diagrams from text
    poetry # Python dependency management and packaging
    rustup # Rust toolchain installer
    sesh # Smart session manager for tmux
    sqlite # SQL database engine
    zeal # Offline documentation browser

    # Editors & Language Servers
    pandoc # Universal markup converter
    pyright # Static type checker for Python
    terraform-ls # Terraform language server
    unstable.tree-sitter # Parser generator and incremental parsing library
    tridactyl-native # Native messaging host for Tridactyl Firefox addon
    vim # Vi Improved text editor
    vscode # Visual Studio Code editor
    yarn # Fast, reliable JavaScript package manager

    # Python Environment
    (python312.withPackages (p: with p; [
      boto3 # AWS SDK for Python
      coverage # Code coverage measurement for Python
      debugpy # Python debugger for Neovim DAP
      pip # Python package installer
      pygments # Syntax highlighting package
      pytest # Python testing framework
      pytest-mock # Thin wrapper around mock for pytest
      pyyaml # YAML parser and emitter for Python
      requests # HTTP library for Python
    ]))

    # Audio & Multimedia
    alsa-lib-with-plugins # Advanced Linux Sound Architecture libraries
    alsa-lib-with-plugins.dev # ALSA development files
    feh # Fast and light image viewer
    noisetorch # Real-time microphone noise suppression
    pamixer # PulseAudio command-line mixer
    pavucontrol # PulseAudio volume control GUI
    playerctl # Media player controller
    poppler_utils # PDF rendering library utilities
    portaudio # Portable audio I/O library
    pulseaudio # Sound server system
    yewtube # YouTube client in the terminal
    yt-dlp # YouTube and other video downloader

    # Window Manager & Desktop Environment
    conky # System monitor for X
    dmenu # Dynamic menu for X
    dunst # Notification daemon
    ffmpegthumbnailer # Lightweight video thumbnailer
    leftwm # Tiling window manager written in Rust
    light # Program to control backlight
    lxrandr # Monitor configuration tool
    maim # Screenshot utility
    picom # X compositor
    polybar # Status bar for window managers
    quickemu # Quick virtual machine creation and management
    rofi # Window switcher and application launcher
    xclip # Command line clipboard utility
    xdg-user-dirs # Tool to help manage user directories
    xsel # Command line clipboard utility (alternative to xclip)

    # iOS Support
    libimobiledevice # Library to communicate with iOS devices
    ifuse # FUSE filesystem for iOS devices

    # Nix Tools
    niv # Dependency management for Nix
    nix-direnv # Integration of direnv with Nix

  ] ++ (with nodePackages; [
    bash-language-server # Bash language server for IDEs
    typescript # TypeScript language
    typescript-language-server # TypeScript language server
    yaml-language-server # YAML language server
    npm # Node package manager
    pnpm # Fast, disk space efficient package manager
    yarn # JavaScript package manager
  ]) ++ (with pkgs; [
    # Packages from unstable channel
    unstable.neovim # Hyperextensible Vim-based text editor
    unstable.devenv # Fast, declarative, reproducible development environments
    unstable.svu # Semantic Version Util v3.x
    # Claude Code from the claude-code-nix flake
    claude-code # Claude AI coding assistant CLI
  ]);
}

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
    obsidian # Knowledge base and note-taking application
    zathura # PDF/document viewer

    # Terminal Tools & Utilities
    # Core tools (age, bash, curl, file, fzf, gh, jq, just, tmux, unzip, yq-go)
    # are provided by custom.minimal module
    # Development tools (chezmoi, direnv) are in custom.development module
    atuin # Shell history sync, search and backup
    envsubst # Substitutes environment variables in shell format strings
    fuse # Filesystem in Userspace
    gitFull # Git version control system with all features
    hledger # Plain text accounting
    libnotify # Desktop notification library
    libzip # Library for reading, creating, and modifying zip archives
    miller # Like awk, sed, cut, join for CSV, TSV, and JSON
    pay-respects # Press F to pay respects in the terminal
    speechd # Common interface to speech synthesis
    topgrade # Upgrade all the things (system packages, plugins, etc.)
    upterm # Secure terminal sharing
    viddy # Modern watch command with diff highlighting

    # Modern CLI Replacements (additional desktop tools)
    # Core modern CLI tools (bat, eza, ripgrep, fd, bottom, delta, lazygit)
    # are provided by custom.minimal module
    pstree # Show the set of running processes as a tree
    difftastic # Structural diff tool that understands syntax
    dua # Disk usage analyzer (alternative to du)
    lfs # List file system info (modern lsfd)
    lsd # Modern ls with colors and icons
    pipr # Interactive pipe evaluation tool
    procs # Modern replacement for ps
    sd # Modern replacement for sed
    xcp # Modern replacement for cp with progress
    zoxide # Modern replacement for cd with frecency

    # Documentation & Help
    cheat # Create and view interactive cheatsheets

    # Desktop Integration
    # Note: kdeconnect is enabled as a program in services.nix
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
    clang # C language family frontend for LLVM
    dive # Docker image explorer and layer analyzer
    git-branchless # High-velocity, monorepo-scale workflow for Git
    gnumake # GNU Make build automation tool
    go # Go programming language
    gopls # Go language server
    lua5_1 # Lua 5.1 interpreter (needed for nvim-dap-python)
    luarocks # Package manager for Lua
    meilisearch # Fast, open-source search engine
    nil # Nix language server
    nodejs # JavaScript runtime built on Chrome's V8 engine
    openjdk # Open Java Development Kit
    pkg-config # Helper tool for compiling applications and libraries
    plantuml # Tool to generate UML diagrams from text
    poetry # Python dependency management and packaging
    rustup # Rust toolchain installer
    sqlite # SQL database engine
    zeal # Offline documentation browser

    # Editors & Language Servers
    pandoc # Universal markup converter
    unstable.tree-sitter # Parser generator and incremental parsing library
    tridactyl-native # Native messaging host for Tridactyl Firefox addon
    vim # Vi Improved text editor

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
    autorandr # Automatic display configuration
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

    # Development tools (neovim, devenv, claude-code, nix-direnv, niv, svu)
    # are provided by custom.development module
  ];
}

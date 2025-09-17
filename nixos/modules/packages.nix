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
    # Desktop applications
    alacritty
    awscli2
    baobab
    brave
    firefox
    gimp
    gnome-disk-utility
    libnotify
    playerctl
    speechd
    transmission_3
    tridactyl-native
    zathura
    zoom-us

    # Terminal tools
    age # Encryption tool for chezmoi
    atuin
    bash
    unstable.chezmoi # Use latest version from unstable
    curl
    devbox # Instant, portable dev environments
    direnv
    dive # Docker image explorer and layer analyzer
    doggo
    envsubst
    file
    fuse
    fzf
    gh
    git-branchless # High-velocity, monorepo-scale workflow for Git
    gitFull
    gitAndTools.gh
    hledger
    jq
    just # Command runner similar to make
    libzip
    miller
    pay-respects
    sesh # Smart session manager for tmux
    stern # Multi-pod and container log tailing for Kubernetes
    tmux
    topgrade
    unzip
    upterm # Secure terminal sharing
    viddy # Modern watch command
    yq-go

    # iOS support
    libimobiledevice
    ifuse

    # Nix tools
    niv
    nix-direnv

    # Modern CLI replacements
    bat # cat
    bottom # htop
    delta # diff
    difftastic # diff
    dua # disk usage analyzer
    eza # ls
    fd # find
    lfs # lsfd
    lsd # ls with colors
    pipr # interactive pipe evaluation
    procs # ps
    ripgrep # grep
    sd # sed
    xcp # cp
    zoxide # cd+fzf

    # Documentation and help
    cheat
    navi
    tealdeer

    # Security
    bitwarden
    credstash
    gnupg
    keychain
    libsecret
    openssl
    openssl.dev

    # Networking
    aws-sso-cli # AWS SSO credential helper
    nss
    nssTools
    ntfs3g
    rclone
    speedtest-cli # Internet bandwidth speed test
    syncthing
    sysdig
    trippy

    # Development
    bear
    bun # Fast JavaScript runtime and package manager
    clang
    gnumake
    go
    gopls
    krew # kubectl plugin manager
    luarocks
    meilisearch
    nil # Nix language server
    openjdk
    pkg-config
    plantuml
    poetry
    rustup
    sqlite
    zeal

    # Editors and language servers
    neovim
    pandoc
    pyright
    terraform-ls
    tree-sitter
    vim
    vscode
    yarn

    # Python environment
    (python312.withPackages (p: with p; [
      boto3
      coverage
      debugpy # Python debugger for Neovim DAP
      pip
      pygments
      pytest
      pytest-mock
      pyyaml
      requests
    ]))

    # Multimedia
    alsa-lib-with-plugins
    alsa-lib-with-plugins.dev
    feh
    noisetorch
    pamixer
    pavucontrol
    poppler_utils
    portaudio
    pulseaudio
    yewtube # YouTube in the terminal
    yt-dlp # YouTube and other video downloader

    # Window manager and desktop
    conky
    dmenu
    dunst
    ffmpegthumbnailer
    leftwm
    light
    lxrandr
    maim
    picom
    polybar
    quickemu
    rofi
    xclip
    xdg-user-dirs
    xsel

  ] ++ (with nodePackages; [
    bash-language-server
    typescript
    typescript-language-server
    yaml-language-server
    npm
    pnpm
    yarn
  ]) ++ (with pkgs; [
    # Packages from unstable channel
    unstable.devenv
    unstable.svu # Semantic Version Util v3.x
    # Claude Code from the claude-code-nix flake
    claude-code
  ]);
}

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

    # Terminal tools
    atuin
    bash
    chezmoi
    curl
    devbox
    direnv
    doggo
    envsubst
    file
    fuse
    fzf
    gh
    gitFull
    gitAndTools.gh
    hledger
    jq
    libzip
    miller
    pay-respects
    sesh
    tmux
    topgrade
    unzip
    yq-go

    # iOS support
    libimobiledevice
    ifuse

    # Nix tools
    devenv
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
    nss
    nssTools
    ntfs3g
    rclone
    syncthing
    sysdig
    trippy

    # Development
    bear
    clang
    # claude-code  # Not available in nixpkgs, installed separately
    gnumake
    go
    gopls
    luarocks
    meilisearch
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
  ]);
}

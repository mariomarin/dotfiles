# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# Import NUR (Nix User Repository)
{ config, pkgs, lib, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
    
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  boot.initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "thinkpad_acpi" ];
  boot.initrd.kernelModules = [ "acpi_call" "kvm-intel" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ] ++ [ pkgs.linuxPackages.sysdig ];

  
  boot.plymouth = {
    enable = true;
    themePackages = [(pkgs.adi1090x-plymouth-themes.override {selected_themes = ["owl"];})];
    theme = "owl";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.extraOptions = ''
    trusted-users = root mario
    extra-substituters = https://devenv.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
  '';

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking = {
    nameservers = [ "127.0.0.1" "::1" ];
    # If using dhcpcd:
    #dhcpcd.extraConfig = "nohook resolv.conf";
    networkmanager.enable = true;
    # Use dns-crypt to resolve DNS lookups
    networkmanager.dns = "none";
    # This is required so that pod can reach the API server (running on port 6443 by default)
    firewall = {
      checkReversePath = false;
      allowedTCPPorts = [
        443
        8081
        6443
        19000
        19001
      ];
    };
  };
  
  # Set your time zone.
  time.timeZone = "America/Bogota";
  #time.timeZone = "Europe/London";
  #time.timeZone = "Europe/Rome";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_CO.UTF-8";
    LC_IDENTIFICATION = "es_CO.UTF-8";
    LC_MEASUREMENT = "es_CO.UTF-8";
    LC_MONETARY = "es_CO.UTF-8";
    LC_NAME = "es_CO.UTF-8";
    LC_NUMERIC = "es_CO.UTF-8";
    LC_PAPER = "es_CO.UTF-8";
    LC_TELEPHONE = "es_CO.UTF-8";
    LC_TIME = "es_CO.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "altgr-intl";
    # displayManager.sddm.enable = true;
    # displayManager.gdm.enable = true;
    displayManager.lightdm = {
      enable = true;
      greeters.slick = {
        enable = true;
        theme.name = "Zukitre-dark";
      };
    };
    windowManager.leftwm.enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    videoDrivers = ["modesetting"];
  };

  xdg = {
    autostart.enable = true;
  };

  # A socket daemon to multiplex connections from and to iOS devices 
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  services.displayManager.defaultSession = "xfce+leftwm";
  
  services.libinput = {
    # https://search.nixos.org/options?channel=unstable&show=services.xserver.libinput.enable
    # XServer - LibInput - Enable
    enable = true;
    # XServer - LibInput - Mouse & Mousepad Configuration
    mouse = {
      # XServer - LibInput - Mouse - Tapping
      tapping = true;
      # XServer - LibInput - Mouse - Scroll Method
      scrollMethod = "twofinger";
      # XServer - LibInput - Mouse - Enable Horizontal Scrolling
      horizontalScrolling = true;
      # XServer - LibInput - Mouse - Disable Left Handed Configuration
      leftHanded = false;
    };
  };

  # Fingerprint sensor
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.xscreensaver.fprintAuth = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mario = {
    isNormalUser = true;
    description = "mario";
    extraGroups = [
      "adbusers"
      "docker"
      "kvm"
      "libvirtd"
      "networkmanager"
      "podman"
      "qemu-libvirtd"
      "wheel"
    ];
    packages = with pkgs; [
      # ...
      # (wrapOBS {
      #   plugins = with obs-studio-plugins; [
      #     wlrobs
      #     droidcam-obs
      #     obs-backgroundremoval
      #     obs-pipewire-audio-capture
      #   ];
      # })
    ];
    shell = pkgs.zsh;
    subUidRanges = [ { count = 100000; startUid = 65536; } ];
    subGidRanges = [ { count = 100000; startGid = 65536; } ];
  };

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import <nixos-unstable> {
        config = config.nixpkgs.config;
      };
      nur = import (builtins.fetchTarball
        "https://github.com/nix-community/NUR/archive/master.tar.gz"
      ) {
        inherit pkgs;
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # desktop programs
    alacritty
    awscli2
    baobab
    brave
    curl
    feh
    firefox
    gimp
    gnome-disk-utility
    libnotify
    playerctl
    speechd
    transmission_3
    tridactyl-native
    zathura

    # cli tools
    atuin
    bash
    chezmoi
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
    libzip
    jq
    miller
    sesh
    pay-respects
    tmux
    topgrade
    unzip
    yq-go

    # iOS
    libimobiledevice
    ifuse # optional, to mount using 'ifuse'

    # nix
    devenv
    niv
    nix-direnv
    nox

    # Rewritten in Rust
    # Modern Alternatives of Command-Line Tools
    bat # cat
    bottom # htop
    delta # diff
    dua # Disk Usage Analyzer
    difftastic # diff
    eza # ls
    fd # find
    lfs # lsfd - list file descriptors
    lsd # ls command with a lot of pretty colors and some other stuff.
    pipr # interactive pipe evaluation
    procs # ps
    ripgrep # grep
    sd # sed
    xcp # cp
    zoxide # cd+fzf

    # pdf cli manipulation
    poppler_utils

    # help and manuals
    cheat
    navi
    tealdeer

    # security
    bitwarden
    credstash
    gnupg
    keychain
    libsecret
    openssl
    openssl.dev

    # networking
    nss
    nssTools
    ntfs3g
    rclone
    syncthing
    sysdig
    trippy

    # coding
    bear
    clang
    claude-code
    gnumake
    go
    gopls
    meilisearch
    openjdk
    pkg-config
    plantuml
    poetry
    rustup
    sqlite
    zeal

    # editor
    neovim
    pandoc
    pyright
    ruff
    shellcheck
    shfmt
    terraform-ls
    tree-sitter
    vim
    vscode
    yarn # Needed for neovim lsp and tree sitter.

    (python312.withPackages (p: with p; [
      autoflake
      black
      boto3
      coverage
      flake8
      isort
      pip
      pycodestyle
      pyflakes
      pygments
      pytest
      pytest-mock
      pyyaml
      requests
    ]))

    # multimedia
    alsa-lib-with-plugins
    alsa-lib-with-plugins.dev
    noisetorch
    pamixer
    pavucontrol
    portaudio
    pulseaudio # only needed for pactl, since I use pipewire

    # window manager
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
    # Node.js packages
      bash-language-server
      prettier
      typescript
      typescript-language-server
      yaml-language-server
      npm
      pnpm
      yarn # Needed for neovim lsp and tree sitter.
  ]);

  # fonts
  fonts.packages = with pkgs; [
    corefonts
    nerd-fonts.iosevka
    nerd-fonts.noto
    nerd-fonts.roboto-mono
    nerd-fonts.symbols-only
  ];
  fonts.fontDir.enable = true;
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = ["Iosevka"];
      emoji = [ "Noto Color Emoji"];
      sansSerif = [ "FreeSans" ];
      serif = [ "FreeSerif" ];
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.light.enable = true;

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
    plugins = with pkgs.obs-studio-plugins; [
      droidcam-obs
    ];
  }; 

  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false; # let the user set the completion settings
  };
  
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  systemd = {
    user.services = {
      polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };
  };

  # Remove sound.enable or turn it off if you had it set previously, it seems to cause conflicts with pipewire
  #sound.enable = false;

  # Gnome keyring
  security.polkit.enable = true;
  security.pam.services.lightdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  # localhost certificate
  security.pki.certificates = [(builtins.readFile ../ssl/certs/localhost.crt)];

  # Thunar
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  
  # Bluetooth
  services.blueman.enable = true;
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # Needed for Bluetooth audio
    extraConfig.pipewire."context.modules" = [
      { name = "libpipewire-module-bluez5"; }
    ];

    wireplumber.enable = true;
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-bluez.conf" ''
        monitor.bluez.properties = {
          bluez5.roles = [ a2dp_sink a2dp_source bap_sink bap_source hsp_hs hsp_ag hfp_hf hfp_ag ]
          bluez5.codecs = [ sbc sbc_xq aac ]
          bluez5.enable-sbc-xq = true
          bluez5.hfphsp-backend = "native"
        }
      '')
    ];
    wireplumber.extraConfig.bluetoothEnhancements = {
      "monitor.bluez.properties" = {
          #"bluez5.codecs" = [ "sbc" "sbc_xq" "aac" ];
          "bluez5.enable-hw-volume" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-sbc-xq" = true;
          "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
      };
    };
  };

  services.interception-tools = {
    enable = true;
    udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
             EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    '';
  };

  # Power manager
  services.upower.enable = true;

  # Emacs daemon
  services.emacs.enable = true;

  # Rclone with cloud storage, like Dropbox
  programs.fuse.userAllowOther = true;
  # https://discourse.nixos.org/t/fusermount-systemd-service-in-home-manager/5157
  # https://aur.archlinux.org/cgit/aur.git/tree/rclone@.service?h=rclone-mount-service
  # https://gist.github.com/kabili207/2cd2d637e5c7617411a666d8d7e97101
  # https://devblog.jpcaparas.com/creating-multiple-rclone-mounts-as-systemd-user-services-using-template-unit-files-c98b87014204
  systemd.user.services."rclone@" = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    enable = true;
    description="rclone: Remote FUSE filesystem for cloud storage config %i";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type="notify";
      ExecStartPre="/run/current-system/sw/bin/mkdir -p -p %h/mnt/%i";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount \
          --config=%h/.config/rclone/rclone.conf \
          --vfs-cache-mode writes \
          --vfs-cache-max-size 100M \
          --log-level INFO \
          --log-file /tmp/rclone-%i.log \
          --umask 022 \
          --allow-other \
          %i: %h/mnt/%i
      '';
      ExecStop="${pkgs.fuse}/fusermount -u %h/mnt/%i";
    };
  };

  # captive browser
  programs.captive-browser.enable = true;
  programs.captive-browser.interface = "wlp4s0";
  
  # nix options for derivations to persist garbage collection
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
  };
  environment.pathsToLink = [
    "/share/nix-direnv"
  ];
  # if you also want support for flakes
  #  nixpkgs.overlays = [
  # (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; } )
  # (let
  #   pinnedPkgs = import(pkgs.fetchFromGitHub {
  #     owner = "NixOS";
  #     repo = "nixpkgs";
  #     rev = "b6bbc53029a31f788ffed9ea2d459f0bb0f0fbfc";
  #     sha256 = "sha256-JVFoTY3rs1uDHbh0llRb1BcTNx26fGSLSiPmjojT+KY=";
  #   }) {};
  # in
  # final: prev: {
  #   docker = pinnedPkgs.docker;
  #   docker-compose = pinnedPkgs.docker-compose;
  # })
  #];
   
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Podman
  # virtualisation.docker.enable = false;
  # virtualisation.podman.enable = true;
  # virtualisation.podman.dockerCompat = true;
  # virtualisation.podman.dockerSocket.enable = true;
  # virtualisation.podman.defaultNetwork.dnsname.enable = true;

  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  virtualisation.libvirtd.enable = true;

  # https://discourse.nixos.org/t/thinkpad-t470s-power-management/8141/4
  # services.tlp = {
  #   enable = true;
  #   settings = {
  #     CPU_SCALING_GOVERNOR_ON_BAT="schedutil";
  #     CPU_SCALING_GOVERNOR_ON_AC="schedutil";

  #     # The following prevents the battery from charging fully to
  #     # preserve lifetime. Run `tlp fullcharge` to temporarily force
  #     # full charge.
  #     # https://linrunner.de/tlp/faq/battery.html#how-to-choose-good-battery-charge-thresholds
  #     START_CHARGE_THRESH_BAT0=5;
  #     STOP_CHARGE_THRESH_BAT0=95;

  #     # 100 being the maximum, limit the speed of my CPU to reduce
  #     # heat and increase battery usage:
  #     # CPU_MAX_PERF_ON_AC=100;
  #     # CPU_MAX_PERF_ON_BAT=5;
  #     # SOUND_POWER_SAVE_ON_AC=0;
  #     # SOUND_POWER_SAVE_ON_BAT=1;
  #   };
  # };

  # services.udev.extraRules = lib.mkMerge [
  #   # autosuspend USB devices
  #   ''ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"''
  #   # autosuspend PCI devices
  #   ''ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="auto"''
  #   # disable Ethernet Wake-on-LAN
  #   ''ACTION=="add", SUBSYSTEM=="net", NAME=="enp*", RUN+="${pkgs.ethtool}/sbin/ethtool -s $name wol d"''
  #   # https://github.com/polybar/polybar-scripts/tree/master/polybar-scripts/battery-combined-udev
  #   ''SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="0", \
  #     RUN+="${pkgs.stdenv.shell} -c /home/mario/.config/polybar/battery-combined-udev.sh --update"''
  #   ''SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_ONLINE}=="1", \
  #     RUN+="${pkgs.stdenv.shell} -c /home/mario/.config/polybar/battery-combined-udev.sh --update"''
  # ];

  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };

      # You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
      # server_names = [ ... ];
    };
  };

  # services.nordvpn.enable = true;

  systemd.services.dnscrypt-proxy2.serviceConfig = {
    StateDirectory = "dnscrypt-proxy";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}

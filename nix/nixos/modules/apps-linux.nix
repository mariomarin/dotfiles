# Desktop-specific packages module
# GUI applications and desktop utilities for NixOS
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

  # Enable Firefox with NixOS integration
  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages = [ pkgs.tridactyl-native ];
  };

  # System packages (Linux-specific desktop apps)
  # Common cross-platform apps are in common/modules/apps.nix
  environment.systemPackages = with pkgs; [
    # Linux Desktop Applications
    baobab # Disk usage analyzer with graphical interface
    gnome-disk-utility # Disk management utility
    zathura # PDF/document viewer

    # Keyboard remapping
    kanata-tray # System tray for kanata (custom pkg)

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

    # Terminal Tools & Utilities
    fuse # Filesystem in Userspace
    hledger # Plain text accounting
    speechd # Common interface to speech synthesis

    # System utilities
    exfatprogs # exFAT filesystem utilities
    nss # Network Security Services
    nssTools # NSS security tools
    ntfs3g # NTFS filesystem driver

    # Audio & Multimedia
    alsa-lib-with-plugins # Advanced Linux Sound Architecture libraries
    alsa-lib-with-plugins.dev # ALSA development files
    feh # Fast and light image viewer
    mpv # Lightweight media player
    noisetorch # Real-time microphone noise suppression
    pamixer # PulseAudio command-line mixer
    pavucontrol # PulseAudio volume control GUI
    playerctl # Media player controller
    poppler_utils # PDF rendering library utilities
    portaudio # Portable audio I/O library
    pulseaudio # Sound server system
  ];
}

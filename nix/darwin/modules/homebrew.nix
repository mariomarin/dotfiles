{ config, pkgs, lib, ... }:

{
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap"; # Remove unlisted casks

    # Third-party taps
    taps = [
      "nikitabobko/tap" # AeroSpace window manager
    ];

    # Only apps not available in nixpkgs or better via homebrew on macOS
    # NOTE: Karabiner-DriverKit-VirtualHIDDevice installed separately for kanata
    # (full karabiner-elements conflicts with kanata - grabs keyboard exclusively)
    casks = [
      "firefox" # Better macOS integration via homebrew
      "nikitabobko/tap/aerospace" # Tiling window manager (i3-like)
      "windows-app" # Microsoft Windows App (Remote Desktop)
    ];
  };
}

{ config, pkgs, lib, ... }:

{
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap"; # Remove unlisted casks

    # Only apps not available in nixpkgs or better via homebrew on macOS
    casks = [
      "firefox" # Better macOS integration via homebrew
      "karabiner-elements" # Includes DriverKit VirtualHIDDevice for kanata
      "windows-app" # Microsoft Windows App (Remote Desktop)
    ];
  };
}

{ config, pkgs, lib, ... }:

{
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap"; # Remove unlisted casks

    # Only apps not available in nixpkgs
    # Prefer nixpkgs for both CLI and GUI apps when available
    casks = [
      "windows-app" # Microsoft Windows App (Remote Desktop)
    ];
  };
}

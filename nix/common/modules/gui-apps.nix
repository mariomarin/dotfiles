# Shared GUI applications for both NixOS and nix-darwin
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Web Browsers
    firefox
    brave

    # Terminal Emulators
    alacritty

    # Productivity
    obsidian
    bitwarden-desktop

    # Image Editing
    gimp

    # File Sync
    syncthing
  ];

  programs.firefox.enable = true;
}

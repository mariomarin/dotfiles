# Shared GUI applications for both NixOS and nix-darwin
# Cross-platform graphical applications that work on Linux and macOS
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Web Browsers
    firefox # Open-source web browser
    brave # Privacy-focused web browser

    # Terminal Emulators
    alacritty # GPU-accelerated terminal emulator (works on both platforms)

    # Productivity
    obsidian # Knowledge base and note-taking
    bitwarden-desktop # Password manager GUI

    # Media Viewers
    # Image viewers
    # Note: feh is Linux-only (X11), macOS has Preview
    # zathura is Linux-only (X11), macOS has Preview for PDFs

    # Image Editing
    gimp # GNU Image Manipulation Program (available on both)

    # File Sync
    syncthing # Continuous file synchronization

    # Media Players
    # VLC, MPV, etc. available on both platforms via nixpkgs
  ];

  # Firefox is available on both platforms
  programs.firefox = {
    enable = true;
  };
}

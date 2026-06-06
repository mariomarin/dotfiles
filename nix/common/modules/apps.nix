# Shared GUI applications for both NixOS and nix-darwin
# NOTE: Do NOT use pkgs.stdenv.isLinux here - causes infinite recursion with overlays
# Platform-specific packages go in apps-linux.nix (NixOS) or packages.nix (Darwin)
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Web Browsers
    brave

    # Terminal Emulators
    alacritty

    # Productivity
    obsidian
    vscode

    # File Sync
    syncthing
  ];
}

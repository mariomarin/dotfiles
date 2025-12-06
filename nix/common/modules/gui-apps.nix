# Shared GUI applications for both NixOS and nix-darwin
{ pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # Web Browsers (firefox via homebrew on darwin)
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
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux-only: Firefox from nixpkgs
    firefox
  ];

  # NixOS-only option
  programs.firefox.enable = lib.mkIf pkgs.stdenv.isLinux true;
}

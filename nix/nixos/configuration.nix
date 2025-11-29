# Main NixOS configuration - module imports
# Host-specific configurations (hardware, hostname, etc.) are in hosts/ directory
# Universal settings (nix config, gc, etc.) are in common.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    # Core modules - conditionally applied based on host type
    ./modules/boot.nix
    ./modules/networking.nix
    ./modules/locale.nix
    ./modules/minimal.nix
    ./modules/development.nix
    ./modules/desktop.nix
    ./modules/users.nix
    ./modules/desktop-packages.nix
    ./modules/packages/additional-tools.nix
    ./modules/services.nix
    ./modules/virtualization.nix
    ./modules/security.nix
    ./modules/system/fonts.nix
  ];
}

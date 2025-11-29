# Main NixOS configuration - module imports
# Host-specific configurations (hardware, hostname, etc.) are in hosts/ directory
# Universal settings (nix config, gc, etc.) are in common.nix
#
# NOTE: These modules are NixOS-specific (use Linux kernel, systemd, etc.)
# Darwin (macOS) uses its own separate configuration in nix/darwin/
{ config, pkgs, lib, ... }:

{
  imports = [
    # Core modules - conditionally applied based on host type
    # These modules use `config.wsl.enable or false` to disable on WSL
    ./modules/boot.nix # Boot loader, Plymouth (disabled on WSL)
    ./modules/networking.nix # NetworkManager, DNS (disabled on WSL)
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

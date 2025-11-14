# Common NixOS configuration shared by all hosts
# Contains only universal settings that apply regardless of host type
{ config, pkgs, lib, ... }:

{
  # Core system settings
  # Note: system.stateVersion should remain at the version you first installed
  # It does NOT need to be changed when upgrading NixOS versions
  system.stateVersion = "24.11";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow specific insecure packages (uncomment as needed)
  # nixpkgs.config.permittedInsecurePackages = [
  #   "qtwebengine-5.15.19"
  # ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Nix daemon configuration
  nix.extraOptions = ''
    trusted-users = root mario
    extra-substituters = https://devenv.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
  '';

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 15d";
  };

  # Keep derivations for direnv
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
  };

  # Path links for nix-direnv integration
  environment.pathsToLink = [
    "/share/nix-direnv"
  ];
}

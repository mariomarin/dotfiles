# macOS-specific packages from nixpkgs
# Prefer nixpkgs over Homebrew for better reproducibility
{ pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    pkgs-unstable.bruno # API testing GUI
    pkgs-unstable.bruno-cli # API testing CLI
    spotify # Music streaming
    tridactyl-native # Native messenger for Tridactyl Firefox addon
  ];
}

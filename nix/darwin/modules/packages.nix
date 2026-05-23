# macOS-specific packages from nixpkgs
# Prefer nixpkgs over Homebrew for better reproducibility
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    spotify # Music streaming
    tridactyl-native # Native messenger for Tridactyl Firefox addon
  ];
}

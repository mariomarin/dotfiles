# macOS-specific packages from nixpkgs
# Prefer nixpkgs over Homebrew for better reproducibility
{ pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    alacritty.terminfo # Terminfo for alacritty terminal
    pkgs-unstable.bruno-cli # API testing CLI
    ext4fuse # Mount ext4 filesystems on macOS (requires macfuse)
    qpdf # PDF transformation and inspection
    spotify # Music streaming
    tridactyl-native # Native messenger for Tridactyl Firefox addon
  ];
}

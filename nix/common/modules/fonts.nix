# Shared font configuration for NixOS and nix-darwin
# Provides Nerd Fonts for Unicode symbols (kanata config, terminal, etc.)
{ pkgs, lib, ... }:

{
  fonts.packages = with pkgs; [
    # System fonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji

    # Programming fonts with ligatures
    jetbrains-mono

    # Nerd fonts (includes Unicode symbols ⎋ ⭾ ⇪ ⌫ ⏎ ␣ etc.)
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    nerd-fonts.symbols-only # Standalone symbols font
  ];
}

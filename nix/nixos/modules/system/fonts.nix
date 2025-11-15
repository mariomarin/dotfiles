# Font configuration for NixOS 25.05+
{ config, pkgs, ... }:

{
  # Enable font configuration
  fonts = {
    fontDir.enable = true;

    # Font packages - using new syntax for NixOS 25.05
    packages = with pkgs; [
      # System fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      dejavu_fonts

      # Programming fonts with ligatures
      jetbrains-mono

      # Icon fonts
      font-awesome
      material-design-icons
      material-icons

      # Individual Nerd fonts (new syntax in 25.05)
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term
      nerd-fonts.roboto-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
    ];

    # Font configuration
    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [ "Noto Serif" "DejaVu Serif" ];
        sansSerif = [ "Noto Sans" "DejaVu Sans" ];
        monospace = [ "JetBrains Mono" "Iosevka Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}

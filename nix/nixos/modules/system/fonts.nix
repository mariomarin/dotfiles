# Font configuration for NixOS
# Imports common fonts and adds NixOS-specific settings
{ config, pkgs, ... }:

{
  imports = [ ../../../common/modules/fonts.nix ];

  # NixOS-specific font settings
  fonts = {
    fontDir.enable = true;

    # Additional NixOS-only fonts
    packages = with pkgs; [
      liberation_ttf
      dejavu_fonts
      font-awesome
      material-design-icons
      material-icons
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

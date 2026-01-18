# macOS-specific packages from nixpkgs
# Prefer nixpkgs over Homebrew for better reproducibility
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    aerospace # Tiling window manager (i3-like)
    kanata # Keyboard remapping
    kanata-tray # System tray for kanata (custom pkg)
    karabiner-dk # DriverKit VirtualHIDDevice (driver-only, no full Karabiner-Elements)
    spotify # Music streaming
    tridactyl-native # Native messenger for Tridactyl Firefox addon
  ];
}

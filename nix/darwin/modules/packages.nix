# macOS-specific packages from nixpkgs
# Prefer nixpkgs over Homebrew for better reproducibility
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    aerospace # Tiling window manager (i3-like)
    kanata # Keyboard remapping
    karabiner-dk # DriverKit VirtualHIDDevice (driver-only, no full Karabiner-Elements)
    spotify # Music streaming
  ];
}

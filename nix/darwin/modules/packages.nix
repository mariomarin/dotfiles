# macOS-specific packages from nixpkgs
# Prefer nixpkgs over Homebrew for better reproducibility
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Keyboard remapping
    kanata
    karabiner-dk # DriverKit VirtualHIDDevice (driver-only, no full Karabiner-Elements)
  ];
}

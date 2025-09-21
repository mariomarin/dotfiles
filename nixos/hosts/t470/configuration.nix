# ThinkPad T470 specific configuration
{ config, pkgs, lib, ... }:

{
  # Set hostname
  networking.hostName = "nixos"; # Change to your preferred hostname

  # Hardware-specific imports
  imports = [
    ../../hardware-configuration.nix # Your current hardware config
  ];

  # Enable desktop environment
  custom.desktop = {
    enable = true;
    type = "gnome"; # or "hyprland" or "leftwm"
  };

  # Enable all desktop-related services
  services.kmonad.enable = true;
  programs.kdeconnect.enable = true;

  # Audio
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Power management for laptop
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # ThinkPad battery thresholds
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Touchpad support
  services.libinput.enable = true;
}

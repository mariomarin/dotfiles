# ThinkPad T470 specific configuration
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../common.nix                  # Universal NixOS settings
    ../../hardware-configuration.nix  # T470 hardware configuration
  ];

  # Set hostname
  networking.hostName = "nixos";

  # Enable desktop environment
  custom.desktop = {
    enable = true;
    type = "leftwm"; # LeftWM + XFCE (no desktop)
  };

  # Enable all desktop-related services
  services.kmonad.enable = true;
  programs.kdeconnect.enable = true;

  # Audio
  services.pulseaudio.enable = false;
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
      START_CHARGE_THRESH_BAT0 = lib.mkForce 75;
      STOP_CHARGE_THRESH_BAT0 = lib.mkForce 80;
    };
  };

  # Touchpad support
  services.libinput.enable = true;
}

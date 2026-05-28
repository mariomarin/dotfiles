# ThinkPad T470 (dendrite) - portable workstation
{ lib, ... }:

{
  imports = [
    ../../common.nix # Universal NixOS settings
    ../../hardware-configuration.nix # T470 hardware configuration
  ];

  # Set hostname
  networking.hostName = "dendrite";

  custom = {
    # Enable CLI tools with modern replacements
    cli = {
      enable = true;
      modernCli = true;
    };

    # Enable development tools
    development.enable = true;

    # Enable desktop environment
    desktop = {
      enable = true;
      type = "leftwm"; # LeftWM + XFCE (no desktop)
    };
  };

  # Enable all desktop-related services
  services = {
    kanata.enable = true;

    # Audio
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Bluetooth
    blueman.enable = true;

    # Power management for laptop
    power-profiles-daemon.enable = false;
    tlp = {
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
    libinput.enable = true;
  };

  programs.kdeconnect.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
}

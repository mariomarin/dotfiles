# WSL-specific NixOS configuration module
{ config, pkgs, lib, options, ... }:

let
  cfg = config.custom.wsl;
  hasWslModule = options ? wsl;
in
{
  options.custom.wsl = {
    enable = lib.mkEnableOption "WSL-specific configuration";

    windowsInterop = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Windows binary execution from WSL";
    };
  };

  config = lib.mkMerge [
    # Only configure wsl options if the nixos-wsl module is available
    (lib.mkIf (cfg.enable && hasWslModule) {
      # Enable WSL integration
      wsl = {
        enable = true;
        defaultUser = "mario";

        # Use systemd as init (NixOS-WSL supports this)
        useWindowsDriver = true;
      };
    })

    (lib.mkIf cfg.enable {

      # Disable incompatible boot/bootloader services
      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
      boot.plymouth.enable = lib.mkForce false;

      # Disable hardware-specific services
      services.fprintd.enable = lib.mkForce false;
      services.tlp.enable = lib.mkForce false;
      services.upower.enable = lib.mkForce false;
      hardware.bluetooth.enable = lib.mkForce false;
      services.blueman.enable = lib.mkForce false;

      # Use WSL networking instead of NetworkManager
      networking.networkmanager.enable = lib.mkForce false;
      networking.dhcpcd.enable = lib.mkForce false;

      # Disable services that require special kernel modules
      services.kmonad.enable = lib.mkForce false;

      # No desktop environment or display manager
      services.xserver.enable = lib.mkForce false;
      services.displayManager.enable = lib.mkForce false;

      # No audio (use Windows audio)
      hardware.pulseaudio.enable = lib.mkForce false;
      services.pipewire.enable = lib.mkForce false;

      # WSL-specific packages (minimal)
      environment.systemPackages = with pkgs; [
        wslu # WSL utilities (wslview, wslpath, etc.)
      ];

      # Configure systemd for WSL
      systemd.services = {
        # Disable services that don't work in WSL
        systemd-resolved.enable = lib.mkForce false;
        systemd-timesyncd.enable = lib.mkForce false;
      };

      # Use Windows time
      time.hardwareClockInLocalTime = lib.mkDefault true;
    })
  ];
}

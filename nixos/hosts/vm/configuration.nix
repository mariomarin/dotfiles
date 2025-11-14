# Headless VM configuration (SSH-only)
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../common.nix  # Universal NixOS settings
  ];

  # Set hostname (will be overridden by VM provisioning usually)
  networking.hostName = "vm-headless";

  # VM-specific hardware configuration
  boot.loader.grub.device = "/dev/vda"; # Common for VMs

  # No desktop environment
  services.xserver.enable = false;

  # Disable desktop-specific services
  services.kmonad.enable = lib.mkForce false;
  programs.kdeconnect.enable = lib.mkForce false;
  hardware.bluetooth.enable = lib.mkForce false;
  services.blueman.enable = lib.mkForce false;

  # No audio needed
  hardware.pulseaudio.enable = false;
  services.pipewire.enable = false;

  # Enable minimal system packages (essential CLI tools only)
  custom.minimal = {
    enable = true;
    modernCli = false;  # Basic tools only, no modern replacements
  };

  # Essential services for headless operation
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      # Only allow key-based authentication
      PubkeyAuthentication = true;
    };
  };

  # Firewall - only SSH by default
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # Disable unnecessary services for VM
  services.avahi.enable = lib.mkForce false;
  services.printing.enable = lib.mkForce false;

  # VM-optimized settings
  boot.kernelParams = [ "console=ttyS0,115200" ];

  # Smaller journal size for VMs
  services.journald.extraConfig = ''
    SystemMaxUse=100M
  '';
}

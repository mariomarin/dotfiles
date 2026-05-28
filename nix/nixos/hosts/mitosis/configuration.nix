# mitosis - Virtual machine for testing and replication
{ lib, ... }:

{
  imports = [
    ../../common.nix # Universal NixOS settings
  ];

  networking = {
    hostName = "mitosis";

    # Firewall - only SSH by default
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # VM-specific hardware configuration
  boot = {
    loader.grub.device = "/dev/vda"; # Common for VMs
    kernelParams = [ "console=ttyS0,115200" ];
  };

  # No desktop environment
  services = {
    xserver.enable = false;

    # Disable desktop-specific services
    kanata.enable = lib.mkForce false;
    blueman.enable = lib.mkForce false;

    # No audio needed
    pipewire.enable = false;

    # Essential services for headless operation
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        # Only allow key-based authentication
        PubkeyAuthentication = true;
      };
    };

    # Disable unnecessary services for VM
    avahi.enable = lib.mkForce false;
    printing.enable = lib.mkForce false;

    # Smaller journal size for VMs
    journald.extraConfig = ''
      SystemMaxUse=100M
    '';
  };

  programs.kdeconnect.enable = lib.mkForce false;

  hardware = {
    bluetooth.enable = lib.mkForce false;
    pulseaudio.enable = false;
  };

  # Enable CLI tools (essential only, no modern replacements)
  custom.cli = {
    enable = true;
    modernCli = false;
  };

}

# mitosis - Virtual machine for testing and replication
_:

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

  # VM disk layout (nixos-generate-config default labels)
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # VM-specific hardware configuration
  boot = {
    loader.grub.device = "/dev/vda"; # Common for VMs
    kernelParams = [ "console=ttyS0,115200" ];
  };

  services = {
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

    # Smaller journal size for VMs
    journald.extraConfig = ''
      SystemMaxUse=100M
    '';
  };

  # Enable CLI tools (essential only, no modern replacements)
  custom.cli = {
    enable = true;
    modernCli = false;
  };
}

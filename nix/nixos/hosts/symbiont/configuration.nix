# symbiont - NixOS on WSL (two systems coexisting)
# Minimal, headless configuration for development via browser/SSH
{ lib, userConfig, ... }:

{
  imports = [
    ../../common.nix # Universal NixOS settings
  ];

  networking = {
    hostName = "symbiont";

    # Firewall - permissive for development
    firewall = {
      enable = true;
      # Allow common dev server ports
      allowedTCPPortRanges = [
        { from = 3000; to = 3999; } # Node/React dev servers
        { from = 4000; to = 4999; } # Various dev servers
        { from = 5000; to = 5999; } # Flask/Python dev servers
        { from = 8000; to = 8999; } # HTTP dev servers
        { from = 9000; to = 9999; } # Various dev servers
      ];
    };
  };

  # Enable WSL support (nixos-wsl module provides these options)
  wsl = {
    enable = true;
    defaultUser = userConfig.username;
    useWindowsDriver = true;
  };

  custom = {
    # No desktop environment - pure CLI
    desktop.enable = lib.mkForce false;

    # Enable CLI tools with modern replacements
    # Per-project tools should come from devenv.nix
    cli = {
      enable = true;
      modernCli = true;
    };

    # Enable development tools
    development.enable = true;
  };

  # Disable incompatible services for WSL
  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    loader.efi.canTouchEfiVariables = lib.mkForce false;
    tmp.cleanOnBoot = true;
  };

  # Enable Docker for containers
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Add user to docker group
  users.users.${userConfig.username}.extraGroups = [ "docker" ];

  services = {
    xserver.enable = lib.mkForce false;
    resolved.enable = lib.mkForce false; # WSL manages resolv.conf

    # Enable SSH server for remote access
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        PubkeyAuthentication = true;
      };
    };

    # Smaller journal size for WSL
    journald.extraConfig = ''
      SystemMaxUse=200M
    '';

    # Disable printing and other desktop services
    avahi.enable = lib.mkForce false;
    printing.enable = lib.mkForce false;
  };
}

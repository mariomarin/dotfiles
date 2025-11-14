# WSL-specific NixOS configuration
# Minimal, headless configuration for development via browser/SSH
{ config, pkgs, lib, ... }:

{
  # Set hostname - can be customized per WSL instance
  networking.hostName = "nixos-wsl";

  # Enable WSL support
  custom.wsl = {
    enable = true;
    windowsInterop = true; # Allow running Windows executables
  };

  # No desktop environment - pure CLI
  custom.desktop.enable = lib.mkForce false;

  # Disable desktop-specific services
  services.kmonad.enable = lib.mkForce false;
  programs.kdeconnect.enable = lib.mkForce false;
  hardware.bluetooth.enable = lib.mkForce false;
  services.blueman.enable = lib.mkForce false;

  # No audio - use Windows audio
  services.pipewire.enable = lib.mkForce false;
  hardware.pulseaudio.enable = lib.mkForce false;

  # Minimal system packages - core CLI tools only
  # Per-project tools should come from devenv.nix
  environment.systemPackages = with pkgs; [
    # Essential tools (everything else via devenv.nix)
    vim
    git
    tmux

    # Modern CLI replacements (universal across projects)
    bat
    eza
    ripgrep
    fd
    bottom
    delta
    lazygit

    # Core utilities
    wget
    curl
    rsync
    jq
    yq-go
  ];

  # Enable Docker for containers
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Add user to docker group
  users.users.mario.extraGroups = [ "docker" ];

  # Firewall - permissive for development
  networking.firewall = {
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

  # Enable SSH server for remote access
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      PubkeyAuthentication = true;
    };
  };

  # Smaller journal size for WSL
  services.journald.extraConfig = ''
    SystemMaxUse=200M
  '';

  # WSL-specific optimizations
  boot.tmp.cleanOnBoot = true;

  # Use systemd-resolved (works better in WSL than dnscrypt)
  services.resolved = {
    enable = true;
    dnssec = "false"; # Can cause issues in WSL
  };

  # Disable printing and other desktop services
  services.avahi.enable = lib.mkForce false;
  services.printing.enable = lib.mkForce false;
}

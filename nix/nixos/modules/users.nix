{ config, pkgs, lib, userConfig, ... }:

{
  # User configuration - username from user.nix
  users.users.${userConfig.username} = {
    isNormalUser = true;
    description = userConfig.username;
    extraGroups = [
      "adbusers"
      "docker"
      "input" # Required for KMonad
      "kvm"
      "libvirtd"
      "networkmanager"
      "podman"
      "qemu-libvirtd"
      "uinput" # Required for KMonad
      "wheel"
    ];
    shell = pkgs.zsh;
    subUidRanges = [{ count = 100000; startUid = 65536; }];
    subGidRanges = [{ count = 100000; startGid = 65536; }];
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false; # let the user set the completion settings
  };
}

{ config, pkgs, lib, ... }:

{
  # User configuration
  users.users.mario = {
    isNormalUser = true;
    description = "mario";
    extraGroups = [
      "adbusers"
      "docker"
      "kvm"
      "libvirtd"
      "networkmanager"
      "podman"
      "qemu-libvirtd"
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

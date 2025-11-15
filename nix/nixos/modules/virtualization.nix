{ config, pkgs, lib, ... }:

{
  # Docker
  virtualisation.docker.enable = true;

  # Libvirt/QEMU
  virtualisation.libvirtd.enable = true;
}

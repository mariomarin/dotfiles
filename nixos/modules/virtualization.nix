{ config, pkgs, lib, ... }:

{
  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  
  # Libvirt/QEMU
  virtualisation.libvirtd.enable = true;
  
  # Alternative: Podman (commented out)
  # virtualisation.podman.enable = true;
  # virtualisation.podman.dockerCompat = true;
  # virtualisation.podman.dockerSocket.enable = true;
  # virtualisation.podman.defaultNetwork.dnsname.enable = true;
}
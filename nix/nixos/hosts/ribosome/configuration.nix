# ribosome - Ubuntu dev server (linux-apt platform)
#
# DOCUMENTATION ONLY: This configuration is NOT evaluated via nixos-rebuild
# since ribosome runs Ubuntu, not NixOS. It documents what would be enabled
# if this were a NixOS host.
#
# Actual package installation: nix/nixos/flake.nix (ribosome-env buildEnv)
# Actual service management: chezmoi systemd files
#
# To add packages: Edit nix/nixos/flake.nix ribosome-env.paths
# To manage services: Edit private_dot_config/systemd/user/
#
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../common.nix
  ];

  # CLI tools (atuin, just, direnv, modern CLI replacements)
  # On NixOS: Applied via nixos-rebuild
  # On ribosome: Mirrored in nix/nixos/flake.nix ribosome-env
  custom.cli = {
    enable = true;
    modernCli = true;
  };

  # Atuin sync server: managed by chezmoi systemd file (linux-apt only)
  # See: private_dot_config/systemd/user/atuin-server.service
}

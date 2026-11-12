# Main NixOS configuration - module imports
# Host-specific configurations (hostname, disks, WSL) are in hosts/ directory
# Universal settings (nix config, gc, etc.) are in common.nix
#
# All NixOS hosts are headless (VM, WSL). Darwin uses nix/darwin/.
{ ... }:

{
  imports = [
    # Shared modules (used by both NixOS and darwin)
    ../common/modules/cli-tools.nix

    ./modules/locale.nix
    ./modules/cli-linux.nix # Linux-specific CLI tools
    ./modules/development.nix
    ./modules/users.nix
    ./modules/packages/additional-tools.nix
    ./modules/services.nix
    ./modules/virtualization.nix
    ./modules/security.nix
  ];
}

# malus - macOS configuration
# Biology theme: Malus (apple genus) for macOS
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../../common/modules/cli-tools.nix # Shared CLI tools with NixOS
    ../../modules/homebrew.nix # Homebrew casks for apps not in nixpkgs
  ];

  # Set hostname
  networking.hostName = "malus";
  networking.computerName = "malus";

  # Enable nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # macOS system defaults (to be configured)
  # system.defaults = {
  #   dock = {
  #     autohide = true;
  #   };
  #   finder = {
  #     AppleShowAllExtensions = true;
  #   };
  # };

  # Used for backwards compatibility
  system.stateVersion = 4;
}

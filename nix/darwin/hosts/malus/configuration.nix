# malus - macOS configuration
# Biology theme: Malus (apple genus) for macOS
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../../common/modules/cli-tools.nix # Shared CLI tools
    ../../../common/modules/gui-apps.nix # Shared GUI applications
    ../../../common/modules/development.nix # Shared development tools
    ../../modules/packages.nix # macOS-specific packages
    ../../modules/homebrew.nix # Homebrew casks for apps not in nixpkgs
  ];

  # Primary user for nix-darwin (required for user-specific options)
  system.primaryUser = "mario";

  # Allow unfree packages (VSCode, etc.)
  nixpkgs.config.allowUnfree = true;

  # Disable nix-darwin's nix-daemon management (use system-installed Nix)
  nix.enable = false;

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

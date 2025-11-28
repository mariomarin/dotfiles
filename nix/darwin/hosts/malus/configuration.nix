# malus - macOS configuration (PLACEHOLDER)
# Biology theme: Malus (apple genus) for macOS
{ config, pkgs, lib, ... }:

{
  # TODO: Implement darwin configuration modules
  # This is a placeholder for future nix-darwin implementation

  # imports = [
  #   ../../modules/packages.nix
  #   ../../modules/homebrew.nix
  #   ../../modules/system.nix
  # ];

  # Set hostname
  networking.hostName = "malus";
  networking.computerName = "malus";

  # Enable nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Basic system packages (placeholder)
  environment.systemPackages = with pkgs; [
    # Core CLI tools will be shared with NixOS
  ];

  # macOS system defaults (placeholder)
  # system.defaults = {
  #   dock = {
  #     autohide = true;
  #   };
  #   finder = {
  #     AppleShowAllExtensions = true;
  #   };
  # };

  # Homebrew configuration (placeholder)
  # homebrew = {
  #   enable = true;
  #   onActivation.cleanup = "zap";
  #   casks = [
  #     # Only apps not in nixpkgs
  #   ];
  # };

  # Used for backwards compatibility
  system.stateVersion = 4;
}

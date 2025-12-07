# malus - macOS configuration
# Biology theme: Malus (apple genus) for macOS
{ config, pkgs, lib, ... }:

let
  # Build environment with all system applications for mkalias
  env = pkgs.buildEnv {
    name = "system-applications";
    paths = config.environment.systemPackages;
    pathsToLink = "/Applications";
  };
in
{
  imports = [
    ../../../common/modules/cli-tools.nix # Shared CLI tools
    ../../../common/modules/gui-apps.nix # Shared GUI applications
    ../../../common/modules/development.nix # Shared development tools
    ../../modules/packages.nix # macOS-specific packages
    ../../modules/homebrew.nix # Homebrew casks for apps not in nixpkgs
  ];

  # Use mkalias instead of symlinks for Nix Apps to enable Spotlight indexing
  # Symlinks aren't indexed by Spotlight, but macOS aliases (created by mkalias) are
  system.activationScripts.applications.text = lib.mkForce ''
    echo "setting up /Applications/Nix Apps..." >&2
    rm -rf /Applications/Nix\ Apps
    mkdir -p /Applications/Nix\ Apps
    find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + | while read -r src; do
      app_name=$(basename "$src")
      echo "copying $src" >&2
      ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
    done
  '';

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

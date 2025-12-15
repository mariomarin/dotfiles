# malus - macOS configuration
# Biology theme: Malus (apple genus) for macOS
{ config, pkgs, lib, ... }:

let
  # Build environment with all system applications
  appEnv = pkgs.buildEnv {
    name = "system-applications";
    paths = config.environment.systemPackages;
    pathsToLink = "/Applications";
  };
in
{
  imports = [
    ../../../common/modules/cli-tools.nix # Shared CLI tools
    ../../../common/modules/apps.nix # Shared GUI applications
    ../../../common/modules/development.nix # Shared development tools
    ../../modules/packages.nix # macOS-specific packages
    ../../modules/homebrew.nix # Homebrew casks for apps not in nixpkgs
    ../../modules/kanata.nix # Kanata keyboard remapping service
    ../../../common/modules/fonts.nix # Shared Nerd Fonts for Unicode symbols
  ];

  # Copy applications instead of symlinking to make Spotlight happy
  # Based on nix-darwin PR #1396 (not yet in stable 25.05)
  # Symlinks aren't indexed by Spotlight, aliases have other issues
  # rsync with --copy-unsafe-links converts nix store symlinks to real files
  system.activationScripts.applications.text = lib.mkForce ''
    echo "setting up /Applications/Nix Apps..." >&2

    targetFolder='/Applications/Nix Apps'

    # Clean up old style symlink to nix store (if exists)
    if [ -L "$targetFolder" ]; then
      rm "$targetFolder"
    fi

    mkdir -p "$targetFolder"

    ${lib.getExe pkgs.rsync} \
      --checksum \
      --copy-unsafe-links \
      --archive \
      --delete \
      --chmod=-w \
      --no-group \
      --no-owner \
      ${appEnv}/Applications/ "$targetFolder"
  '';

  # Enable CLI tools with modern replacements
  custom.cli = {
    enable = true;
    modernCli = true;
  };

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

  # Enable TouchID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Zsh configuration - disable global compinit (Zim handles it)
  programs.zsh.enableGlobalCompInit = false;

  # Syncthing - file synchronization
  launchd.user.agents.syncthing = {
    serviceConfig = {
      Label = "org.syncthing.syncthing";
      ProgramArguments = [ "${pkgs.syncthing}/bin/syncthing" "-no-browser" "-no-restart" ];
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Background";
      StandardOutPath = "/Users/mario/Library/Logs/syncthing.log";
      StandardErrorPath = "/Users/mario/Library/Logs/syncthing.log";
    };
  };

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

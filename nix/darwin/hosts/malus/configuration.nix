# malus - macOS configuration
# Biology theme: Malus (apple genus) for macOS
{ config, pkgs, lib, userConfig, ... }:

let
  username = userConfig.username;
  homeDir = "/Users/${username}";
in
{
  imports = [
    ../../../common/modules/cli-tools.nix # Shared CLI tools
    ../../../common/modules/apps.nix # Shared GUI applications
    ../../../common/modules/development.nix # Shared development tools
    ../../modules/packages.nix # macOS-specific packages
    ../../modules/homebrew.nix # Homebrew casks for apps not in nixpkgs
    ../../modules/kanata.nix # Kanata keyboard remapping service
    ../../modules/xdg-open-svc.nix # Open URLs from remote hosts
    ../../../common/modules/fonts.nix # Shared Nerd Fonts for Unicode symbols
    ../../../common/modules/tmux.nix # Shared tmux plugins configuration
  ];

  # Enable CLI tools with modern replacements
  custom.cli = {
    enable = true;
    modernCli = true;
  };

  # Primary user for nix-darwin (required for user-specific options)
  system.primaryUser = username;

  # Allow unfree packages (VSCode, etc.)
  nixpkgs.config.allowUnfree = true;

  # Disable nix-darwin's nix-daemon management (use system-installed Nix)
  nix.enable = false;

  # Set hostname
  networking.hostName = "malus";
  networking.computerName = "malus";

  # Enable nix flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable TouchID for sudo (reattach for tmux/screen support)
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

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
      StandardOutPath = "${homeDir}/Library/Logs/syncthing.log";
      StandardErrorPath = "${homeDir}/Library/Logs/syncthing.log";
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

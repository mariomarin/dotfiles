# axon - work Mac (nix-darwin)
{ pkgs, userConfig, ... }:

let
  inherit (userConfig) username;
  homeDir = "/Users/${username}";
in
{
  imports = [
    ../../../common/modules/cli-tools.nix
    ../../../common/modules/fonts.nix
    ../../../common/modules/tmux.nix
    ../../modules/xdg-open-svc.nix
    ../../modules/kanata.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      alacritty
      ncurses # terminfo for alacritty/ghostty/tmux
      obsidian
      vscode
      spotify
    ];

    variables.TERMINFO_DIRS = [ "/etc/terminfo" ];
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    brews = [
      "libyaml"
    ];
    casks = [
      "firefox"
      "ghostty"
      "hammerspoon"
      "voiceink"
    ];
  };

  custom.cli = {
    enable = true;
    modernCli = true;
  };

  nixpkgs.config.allowUnfree = true;
  nix.enable = false;

  programs.zsh.enableGlobalCompInit = false;

  launchd.user.agents = {
    # Clipper - clipboard daemon for remote access
    clipper = {
      serviceConfig = {
        Label = "org.local.clipper";
        ProgramArguments = [ "${pkgs.clipper}/bin/clipper" "--address" "127.0.0.1" "--port" "8377" ];
        KeepAlive = true;
        RunAtLoad = true;
        ProcessType = "Background";
      };
    };

    # Syncthing - file synchronization
    syncthing = {
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
  };


  system = {
    primaryUser = username;

    # Compile terminfo into Darwin-compatible letter-based dirs (/etc/terminfo)
    # macOS expects a/alacritty, nix provides 61/alacritty (hex-encoded)
    # zsh reinitializes terminal on TERMINFO_DIRS assignment during /etc/zshenv
    activationScripts.postActivation.text = ''
      mkdir -p /etc/terminfo
      for term in alacritty alacritty-direct ghostty xterm-ghostty; do
        ${pkgs.ncurses}/bin/infocmp -A /run/current-system/sw/share/terminfo "$term" 2>/dev/null | \
          TERMINFO=/etc/terminfo ${pkgs.ncurses}/bin/tic -x - 2>/dev/null || true
      done
    '';

    stateVersion = 4;
  };
}

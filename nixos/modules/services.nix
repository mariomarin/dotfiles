{ config, pkgs, lib, ... }:

{
  imports = [
    ./services/kmonad.nix
  ];
  # Fingerprint sensor
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = lib.mkForce true;
  security.pam.services.xscreensaver.fprintAuth = true;

  # File manager support
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # Power management
  services.upower.enable = true;

  # Polkit authentication agent
  systemd = {
    user.services = {
      polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };
  };

  # Light control
  programs.light.enable = true;

  # KDE Connect - Phone/computer integration
  programs.kdeconnect.enable = true;
}

{ config, pkgs, lib, ... }:

let
  isDesktop = config.custom.desktop.enable or false;
in
{
  imports = [
    ./services/kanata.nix
  ];

  # Syncthing - file synchronization (all hosts)
  services.syncthing = {
    enable = true;
    user = "mario";
    dataDir = "/home/mario";
    configDir = "/home/mario/.config/syncthing";
  };

  # Topgrade - automatic updates (all hosts)
  systemd.user.services.topgrade = {
    description = "Run topgrade to update all packages and plugins";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.topgrade}/bin/topgrade --no-retry --yes";
    };
  };

  systemd.user.timers.topgrade = {
    description = "Run topgrade every 3 days";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15min";
      OnUnitActiveSec = "3d";
      OnCalendar = "Mon,Thu *-*-* 02:00:00";
      Persistent = true;
    };
  };

  # Desktop-only services
  config = lib.mkIf isDesktop {
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
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
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

    # Wallpaper rotation
    systemd.user.services.wallpaper-rotation = {
      description = "Rotate wallpaper using feh";
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        Environment = "DISPLAY=:0";
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.feh}/bin/feh --bg-fill --randomize ~/.wallpapers/*'";
      };
    };

    systemd.user.timers.wallpaper-rotation = {
      description = "Rotate wallpaper every 30 minutes";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnActiveSec = "0";
        OnUnitActiveSec = "30min";
        Persistent = true;
      };
    };

    # Picom compositor
    systemd.user.services.picom = {
      description = "Picom X11 compositor";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.picom}/bin/picom --config %h/.config/picom/picom.conf";
        Restart = "on-failure";
        RestartSec = 1;
      };
    };

    # Polybar status bar
    systemd.user.services.polybar = {
      description = "Polybar status bar";
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wants = [ "tray.target" ];
      wantedBy = [ "default.target" ];
      path = [ "/run/current-system/sw" ];
      serviceConfig = {
        Type = "exec";
        ExecStart = "%h/.config/polybar/launch.sh";
        Restart = "on-failure";
        RestartSec = 2;
      };
    };

    # Battery monitor for Polybar
    systemd.user.services.battery-combined-udev = {
      description = "Battery Combined UDev Monitor for Polybar";
      after = [ "graphical-session.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "%h/.config/polybar/battery-combined-udev.sh";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    # Monitor change handler (restarts polybar on display change)
    systemd.user.services."monitor-change@" = {
      description = "Monitor change handler for %i";
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "oneshot";
        Environment = "DISPLAY=:0";
        ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 2 && systemctl --user restart polybar.service'";
      };
    };

    # Light control
    programs.light.enable = true;

    # KDE Connect - Phone/computer integration
    programs.kdeconnect.enable = true;
  };
}

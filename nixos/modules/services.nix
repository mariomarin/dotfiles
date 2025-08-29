{ config, pkgs, lib, ... }:

{
  # iOS device support
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  # Fingerprint sensor
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.xscreensaver.fprintAuth = true;

  # File manager support
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # Power management
  services.upower.enable = true;

  # Keyboard remapping
  services.interception-tools = {
    enable = true;
    udevmonConfig = ''
      - JOB: "${pkgs.interception-tools}/bin/intercept -g $DEVNODE | ${pkgs.interception-tools-plugins.caps2esc}/bin/caps2esc | ${pkgs.interception-tools}/bin/uinput -d $DEVNODE"
        DEVICE:
          EVENTS:
            EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
    '';
  };

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

  # Rclone mount service
  programs.fuse.userAllowOther = true;
  systemd.user.services."rclone@" = {
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    enable = true;
    description = "rclone: Remote FUSE filesystem for cloud storage config %i";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "notify";
      ExecStartPre = "/run/current-system/sw/bin/mkdir -p -p %h/mnt/%i";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone mount \
          --config=%h/.config/rclone/rclone.conf \
          --vfs-cache-mode writes \
          --vfs-cache-max-size 100M \
          --log-level INFO \
          --log-file /tmp/rclone-%i.log \
          --umask 022 \
          --allow-other \
          %i: %h/mnt/%i
      '';
      ExecStop = "${pkgs.fuse}/bin/fusermount -u %h/mnt/%i";
    };
  };

  # Light control
  programs.light.enable = true;

  # OBS Studio - commented out due to insecure qtwebengine dependency
  # To enable, add to nixpkgs.config.permittedInsecurePackages
  # programs.obs-studio = {
  #   enable = true;
  #   enableVirtualCamera = true;
  #   plugins = with pkgs.obs-studio-plugins; [
  #     droidcam-obs
  #   ];
  # };
}

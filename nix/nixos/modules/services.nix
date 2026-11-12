{ pkgs, lib, userConfig, ... }:

let
  inherit (userConfig) username;
  homeDir = "/home/${username}";
in
{
  config = lib.mkMerge [
    # All hosts
    {
      # Syncthing - file synchronization
      services.syncthing = {
        enable = true;
        user = username;
        dataDir = homeDir;
        configDir = "${homeDir}/.config/syncthing";
      };

      systemd.user = {
        services = {
          # Clipper - clipboard over SSH (localhost only, no network dependency)
          clipper = {
            description = "Clipper clipboard service";
            wantedBy = [ "default.target" ];
            serviceConfig = {
              Type = "simple";
              ExecStart = "${pkgs.clipper}/bin/clipper --address 127.0.0.1 --port 8377";
              Restart = "on-failure";
              RestartSec = 5;
            };
          };

          # Topgrade - automatic updates
          topgrade = {
            description = "Run topgrade to update all packages and plugins";
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pkgs.topgrade}/bin/topgrade --no-retry --yes";
            };
          };
        };

        timers.topgrade = {
          description = "Run topgrade every 3 days";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "15min";
            OnUnitActiveSec = "3d";
            OnCalendar = "Mon,Thu *-*-* 02:00:00";
            Persistent = true;
          };
        };
      };
    }
  ];
}

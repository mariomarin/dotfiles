# Kanata keyboard remapping service for macOS
{ config, pkgs, lib, ... }:

{
  # Kanata LaunchDaemon (runs as root for keyboard access)
  launchd.daemons.kanata = {
    serviceConfig = {
      ProgramArguments = [
        "${pkgs.kanata}/bin/kanata"
        "--cfg"
        "${config.users.users.mario.home}/.config/kanata/darwin.kbd"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardErrorPath = "/tmp/kanata.err.log";
      StandardOutPath = "/tmp/kanata.out.log";
    };
  };
}

# Kanata keyboard remapping service for macOS
# Requires Karabiner-DriverKit-VirtualHIDDevice for virtual keyboard support
# See: https://github.com/jtroo/kanata/discussions/1537
{ config, pkgs, lib, ... }:

let
  karabinerDk = pkgs.karabiner-dk;
  managerApp = "${karabinerDk}/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager";
  daemonApp = "${karabinerDk}/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon";
in
{
  # 1. Karabiner VirtualHIDDevice Manager - activates the driver extension
  # NOTE: This will fail if run from /nix/store (macOS requires /Applications).
  # The extension must be manually activated once via:
  #   sudo "/Applications/Nix Apps/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" activate
  # After that, only the daemon needs to run.
  launchd.daemons.karabiner-vhidmanager = {
    serviceConfig = {
      Label = "org.pqrs.karabiner-vhidmanager";
      ProgramArguments = [ managerApp "activate" ];
      RunAtLoad = true;
      # Don't retry on failure - extension only needs activation once
      KeepAlive = false;
      StandardErrorPath = "/tmp/karabiner-vhidmanager.err.log";
      StandardOutPath = "/tmp/karabiner-vhidmanager.out.log";
    };
  };

  # 2. Karabiner VirtualHIDDevice Daemon - creates the virtual HID device
  # Must run continuously for kanata to connect
  launchd.daemons.karabiner-vhiddaemon = {
    serviceConfig = {
      Label = "org.pqrs.karabiner-vhiddaemon";
      ProgramArguments = [ daemonApp ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive"; # High responsiveness for keyboard input
      StandardErrorPath = "/tmp/karabiner-vhiddaemon.err.log";
      StandardOutPath = "/tmp/karabiner-vhiddaemon.out.log";
    };
  };

  # 3. Kanata keyboard remapper - connects to Karabiner VirtualHIDDevice
  launchd.daemons.kanata = {
    serviceConfig = {
      Label = "org.nixos.kanata";
      ProgramArguments = [
        "${pkgs.kanata}/bin/kanata"
        "--cfg"
        "/Users/${config.system.primaryUser}/.config/kanata/darwin.kbd"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardErrorPath = "/tmp/kanata.err.log";
      StandardOutPath = "/tmp/kanata.out.log";
    };
  };

  # Create required directory for Karabiner socket
  system.activationScripts.postActivation.text = ''
    mkdir -p "/Library/Application Support/org.pqrs/tmp"
    chmod 1777 "/Library/Application Support/org.pqrs/tmp"
  '';
}

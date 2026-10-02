# Kanata keyboard remapping service for macOS
# Requires Karabiner-DriverKit-VirtualHIDDevice for virtual keyboard support
# See: https://github.com/jtroo/kanata/discussions/1537
{ config, pkgs, pkgs-unstable, ... }:

let
  # Use Nix store path directly - TCC permissions will need re-granting on updates,
  # but this avoids dyld library loading issues from copied binaries
  kanataPath = "${pkgs-unstable.kanata}/bin/kanata";
  karabinerDaemon = "${pkgs.karabiner-dk}/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon";
in
{
  # Karabiner VirtualHIDDevice daemon (creates the socket kanata connects to)
  # Must start before kanata
  launchd.daemons.karabiner-vhid = {
    serviceConfig = {
      Label = "org.pqrs.Karabiner-VirtualHIDDevice-Daemon";
      ProgramArguments = [
        karabinerDaemon
        "daemon"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      ProcessType = "Interactive";
      StandardErrorPath = "/tmp/karabiner-vhid.err.log";
      StandardOutPath = "/tmp/karabiner-vhid.out.log";
    };
  };

  # Kanata keyboard remapper
  # Uses Nix store path directly - TCC permissions need re-granting after updates
  # but this avoids dyld library loading issues
  #
  # First-time setup (one-time):
  # 1. Activate Karabiner extension:
  #    sudo "/Applications/Nix Apps/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" activate
  # 2. Approve extension in System Settings > Privacy & Security
  # 3. Grant Input Monitoring to the kanata binary (path shown in kanata-doctor output)
  # 4. After each nix-darwin rebuild that updates kanata, re-grant Input Monitoring
  #
  # IMPORTANT: Do NOT manually run Karabiner-VirtualHIDDevice-Daemon!
  # The launchd service above manages it automatically. Running it manually
  # causes multiple daemon instances that compete and break kanata connection.
  launchd.daemons.kanata = {
    serviceConfig = {
      Label = "org.nixos.kanata";
      ProgramArguments = [
        kanataPath
        "--cfg"
        "/Users/${config.system.primaryUser}/.config/kanata/darwin.kbd"
        "--port"
        "5829"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardErrorPath = "/tmp/kanata.err.log";
      StandardOutPath = "/tmp/kanata.out.log";
    };
  };

  # Karabiner in systemPackages so nix-darwin copies .app to /Applications
  environment.systemPackages = [ pkgs.karabiner-dk ];

  # Create Karabiner socket directory
  system.activationScripts.postActivation.text = ''
    # Create required directory for Karabiner socket
    mkdir -p "/Library/Application Support/org.pqrs/tmp"
    chmod 1777 "/Library/Application Support/org.pqrs/tmp"

    # Kill any manually-started Karabiner daemons to prevent conflicts
    pkill -f "Karabiner-VirtualHIDDevice-Daemon activate" || true
  '';
}

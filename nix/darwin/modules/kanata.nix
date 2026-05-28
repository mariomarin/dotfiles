# Kanata keyboard remapping service for macOS
# Requires Karabiner-DriverKit-VirtualHIDDevice for virtual keyboard support
# See: https://github.com/jtroo/kanata/discussions/1537
{ config, pkgs, pkgs-unstable, lib, ... }:

let
  kanataStablePath = "/usr/local/bin/kanata";
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
  # Binary is copied to stable path so Input Monitoring permission survives updates
  #
  # First-time setup (one-time):
  # 1. Activate Karabiner extension:
  #    sudo "/Applications/Nix Apps/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" activate
  # 2. Approve extension in System Settings > Privacy & Security
  # 3. Grant Input Monitoring to /usr/local/bin/kanata
  #
  # IMPORTANT: Do NOT manually run Karabiner-VirtualHIDDevice-Daemon!
  # The launchd service above manages it automatically. Running it manually
  # causes multiple daemon instances that compete and break kanata connection.
  launchd.daemons.kanata = {
    serviceConfig = {
      Label = "org.nixos.kanata";
      ProgramArguments = [
        kanataStablePath
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

  # Copy kanata to stable path and create Karabiner socket directory
  system.activationScripts.postActivation.text = ''
    # Create required directory for Karabiner socket
    mkdir -p "/Library/Application Support/org.pqrs/tmp"
    chmod 1777 "/Library/Application Support/org.pqrs/tmp"

    # Kill any manually-started Karabiner daemons to prevent conflicts
    # Only kill processes NOT managed by our launchd service
    pgrep -f "Karabiner-VirtualHIDDevice-Daemon activate" | while read pid; do
      echo "Stopping conflicting Karabiner daemon (PID $pid)..."
      kill "$pid" 2>/dev/null || true
    done

    # Copy kanata binary to stable path only if it changed
    new_hash=$(shasum -a 256 ${pkgs-unstable.kanata}/bin/kanata | cut -d' ' -f1)
    old_hash=""
    if [ -f ${kanataStablePath} ]; then
      old_hash=$(shasum -a 256 ${kanataStablePath} | cut -d' ' -f1)
    fi

    if [ "$new_hash" != "$old_hash" ]; then
      cp -f ${pkgs-unstable.kanata}/bin/kanata ${kanataStablePath}
      chmod 755 ${kanataStablePath}
      osascript -e 'display notification "Kanata binary updated — re-grant Input Monitoring in System Settings → Privacy & Security" with title "Kanata"'
    fi
  '';
}

# Kanata keyboard remapping service for macOS
# Requires Karabiner-DriverKit-VirtualHIDDevice for virtual keyboard support
# See: https://github.com/jtroo/kanata/discussions/1537
{ config, pkgs, pkgs-unstable, ... }:

let
  # Wrapper script at stable path that execs Nix store binary
  # TCC permissions are granted to the wrapper (stable path)
  # SIP blocks DYLD_* in launchd, but we can use DYLD_LIBRARY_PATH in the wrapper itself
  # since the wrapper is what launchd runs, not a dyld-loaded binary
  kanataWrapper = pkgs.writeShellScript "kanata-wrapper" ''
    # Set library path for Nix dependencies
    export DYLD_FALLBACK_LIBRARY_PATH="/nix/store:''${DYLD_FALLBACK_LIBRARY_PATH:-}"
    exec "${pkgs-unstable.kanata}/bin/kanata" "$@"
  '';
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
  # Uses wrapper script at stable path (/usr/local/bin/kanata) for TCC permissions
  # Wrapper execs Nix store binary, so permissions survive rebuilds
  #
  # First-time setup (one-time):
  # 1. Activate Karabiner extension:
  #    sudo "/Applications/Nix Apps/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" activate
  # 2. Approve extension in System Settings > Privacy & Security
  # 3. Grant Input Monitoring and Accessibility to /usr/local/bin/kanata
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

  # Install wrapper and create Karabiner socket directory
  system.activationScripts.postActivation.text = ''
    # Create required directory for Karabiner socket
    mkdir -p "/Library/Application Support/org.pqrs/tmp"
    chmod 1777 "/Library/Application Support/org.pqrs/tmp"

    # Kill any manually-started Karabiner daemons to prevent conflicts
    pkill -f "Karabiner-VirtualHIDDevice-Daemon activate" || true

    # Install wrapper script to stable path
    # TCC permissions are granted to this path, wrapper execs Nix store binary
    cp -f ${kanataWrapper} ${kanataStablePath}
    chmod 755 ${kanataStablePath}
  '';
}

# Kanata keyboard remapping service for macOS
# Requires Karabiner-DriverKit-VirtualHIDDevice for virtual keyboard support
# See: https://github.com/jtroo/kanata/discussions/1537
{ config, pkgs, pkgs-unstable, ... }:

let
  # Copy kanata binary and patch library paths to use system libraries
  # TCC requires a stable, signed binary (can't use wrapper scripts)
  # We copy to stable path and use install_name_tool to point to system libs
  kanataStablePath = "/usr/local/bin/kanata";

  # macOS provides libiconv at /usr/lib/libiconv.2.dylib
  systemLibiconv = "/usr/lib/libiconv.2.dylib";
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
  # Copies binary to stable path and patches to use system libraries
  # TCC permissions granted to signed binary (can't use wrapper scripts)
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

  # Copy binary and patch library paths
  system.activationScripts.postActivation.text = ''
    # Create required directory for Karabiner socket
    mkdir -p "/Library/Application Support/org.pqrs/tmp"
    chmod 1777 "/Library/Application Support/org.pqrs/tmp"

    # Kill any manually-started Karabiner daemons to prevent conflicts
    pkill -f "Karabiner-VirtualHIDDevice-Daemon activate" || true

    # Copy kanata binary to stable path for TCC permissions
    # TCC requires actual signed binary, not wrapper script
    cp -f ${pkgs-unstable.kanata}/bin/kanata ${kanataStablePath}
    chmod 755 ${kanataStablePath}

    # Patch library paths to use system libiconv instead of Nix store
    # This avoids dyld failures when running via launchd (SIP blocks DYLD_* vars)
    install_name_tool -change \
      /nix/store/fgrxz4hr8f71hkhsddbvk8nxadpg67bv-libiconv-115.100.1/lib/libiconv.2.dylib \
      ${systemLibiconv} \
      ${kanataStablePath} || true

    # Re-sign with ad-hoc signature (required for TCC)
    codesign --force --sign - ${kanataStablePath}
  '';
}

# Kanata keyboard remapping service for macOS
# Requires Karabiner-DriverKit-VirtualHIDDevice for virtual keyboard support
# See: https://github.com/jtroo/kanata/discussions/1537
{ config, pkgs, lib, ... }:

let
  kanataStablePath = "/usr/local/bin/kanata";
in
{
  # Kanata keyboard remapper
  # Binary is copied to stable path so Input Monitoring permission survives updates
  #
  # First-time setup (one-time):
  # 1. Activate Karabiner extension:
  #    sudo "/Applications/Nix Apps/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" activate
  # 2. Approve extension in System Settings > Privacy & Security
  # 3. Grant Input Monitoring to /usr/local/bin/kanata
  launchd.daemons.kanata = {
    serviceConfig = {
      Label = "org.nixos.kanata";
      ProgramArguments = [
        kanataStablePath
        "--cfg"
        "/Users/${config.system.primaryUser}/.config/kanata/darwin.kbd"
      ];
      RunAtLoad = true;
      KeepAlive = true;
      StandardErrorPath = "/tmp/kanata.err.log";
      StandardOutPath = "/tmp/kanata.out.log";
    };
  };

  # Copy kanata to stable path and create Karabiner socket directory
  system.activationScripts.postActivation.text = ''
    # Copy kanata binary to stable path (preserves Input Monitoring permission)
    cp -f ${pkgs.kanata}/bin/kanata ${kanataStablePath}
    chmod 755 ${kanataStablePath}

    # Create required directory for Karabiner socket
    mkdir -p "/Library/Application Support/org.pqrs/tmp"
    chmod 1777 "/Library/Application Support/org.pqrs/tmp"
  '';
}

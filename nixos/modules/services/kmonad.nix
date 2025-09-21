{ config, pkgs, lib, ... }:

{
  # Enable KMonad for advanced keyboard remapping
  services.kmonad = {
    enable = true;
    keyboards = {
      laptop = {
        # ThinkPad T470 internal keyboard
        # You may need to adjust this path for your specific hardware
        device = "/dev/input/by-path/platform-i8042-serio-0-event-kbd";
        # Read the configuration from the chezmoi-managed location
        config = builtins.readFile "${config.users.users.mario.home}/.config/kmonad/laptop.kbd";
      };
    };
  };

  # Enable uinput module (required for KMonad)
  boot.kernelModules = [ "uinput" ];

  # Set up udev rules for KMonad
  services.udev.extraRules = ''
    # KMonad user access to /dev/uinput
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  # Create uinput group
  users.groups.uinput = { };
}

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
        # Read the configuration from the separate .kbd file
        config = builtins.readFile ./laptop.kbd;
      };
      kinesis = {
        # Kinesis Freestyle 2 USB keyboard
        device = "/dev/input/by-id/usb-KINESIS_FREESTYLE_KB800_KB800_Kinesis_Freestyle-event-kbd";
        # Read the configuration from the separate .kbd file
        config = builtins.readFile ./kinesis.kbd;
      };
      calliope = {
        # Lenovo Calliope USB Keyboard G2
        device = "/dev/input/by-id/usb-LiteOn_Lenovo_Calliope_USB_Keyboard_G2-event-kbd";
        # Read the configuration from the separate .kbd file
        config = builtins.readFile ./calliope.kbd;
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

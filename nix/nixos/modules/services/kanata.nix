{ config, pkgs, lib, ... }:

{
  # Enable Kanata for advanced keyboard remapping
  services.kanata = {
    enable = true;
    keyboards = {
      laptop = {
        # ThinkPad T470 internal keyboard
        devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
        config = builtins.readFile ../../../../private_dot_config/kanata/laptop.kbd;
      };
      kinesis = {
        # Kinesis Freestyle 2 USB keyboard
        devices = [ "/dev/input/by-id/usb-KINESIS_FREESTYLE_KB800_KB800_Kinesis_Freestyle-event-kbd" ];
        config = builtins.readFile ../../../../private_dot_config/kanata/laptop.kbd;
      };
      calliope = {
        # Lenovo Calliope USB Keyboard G2
        devices = [ "/dev/input/by-id/usb-LiteOn_Lenovo_Calliope_USB_Keyboard_G2-event-kbd" ];
        config = builtins.readFile ../../../../private_dot_config/kanata/laptop.kbd;
      };
    };
  };
}

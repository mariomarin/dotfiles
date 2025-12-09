{ config, pkgs, lib, ... }:

{
  # Enable Kanata for advanced keyboard remapping
  # Disabled on WSL - no raw device access
  services.kanata = {
    enable = !(config.wsl.enable or false);
    keyboards = {
      laptop = {
        # ThinkPad T470 internal keyboard
        devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
        extraDefCfg = "process-unmapped-keys yes\n  danger-enable-cmd no";
        config = builtins.readFile ../../../../private_dot_config/kanata/core.kbd;
      };
      kinesis = {
        # Kinesis Freestyle 2 USB keyboard
        devices = [ "/dev/input/by-id/usb-KINESIS_FREESTYLE_KB800_KB800_Kinesis_Freestyle-event-kbd" ];
        extraDefCfg = "process-unmapped-keys yes\n  danger-enable-cmd no";
        config = builtins.readFile ../../../../private_dot_config/kanata/core.kbd;
      };
      calliope = {
        # Lenovo Calliope USB Keyboard G2
        devices = [ "/dev/input/by-id/usb-LiteOn_Lenovo_Calliope_USB_Keyboard_G2-event-kbd" ];
        extraDefCfg = "process-unmapped-keys yes\n  danger-enable-cmd no";
        config = builtins.readFile ../../../../private_dot_config/kanata/core.kbd;
      };
    };
  };
}

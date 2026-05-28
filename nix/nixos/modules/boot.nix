{ config, pkgs, lib, ... }:

let
  isWSL = config.wsl.enable or false;
in
{
  # Boot configuration - only for non-WSL systems
  config = lib.mkIf (!isWSL) {
    boot = {
      # Bootloader
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        efi.efiSysMountPoint = "/boot/efi";
      };

      # Setup keyfile
      initrd = {
        secrets = {
          "/crypto_keyfile.bin" = null;
        };
        # Kernel modules
        availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "thinkpad_acpi" ];
        kernelModules = [ "acpi_call" "kvm-intel" ];
      };

      kernelModules = [ "kvm-intel" ];
      extraModulePackages = with config.boot.kernelPackages; [
        acpi_call
      ] ++ [
        pkgs.linuxPackages.sysdig
      ];

      # Plymouth boot splash
      plymouth = {
        enable = true;
        themePackages = [ (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ "owl" ]; }) ];
        theme = "owl";
      };
    };
  };
}

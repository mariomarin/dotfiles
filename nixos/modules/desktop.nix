{ config, pkgs, lib, ... }:

{
  # X11 configuration
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    xkb.variant = "altgr-intl";

    displayManager.lightdm = {
      enable = true;
      greeters.slick = {
        enable = true;
        theme.name = "Zukitre-dark";
      };
    };

    windowManager.leftwm.enable = true;

    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };

    videoDrivers = [ "modesetting" ];
  };

  services.displayManager.defaultSession = "xfce+leftwm";

  # Input configuration
  services.libinput = {
    enable = true;
    mouse = {
      tapping = true;
      scrollMethod = "twofinger";
      horizontalScrolling = true;
      leftHanded = false;
    };
  };

  # XDG
  xdg.autostart.enable = true;

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # Bluetooth audio
    extraConfig.pipewire."context.modules" = [
      { name = "libpipewire-module-bluez5"; }
    ];

    wireplumber.enable = true;
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-bluez.conf" ''
        monitor.bluez.properties = {
          bluez5.roles = [ a2dp_sink a2dp_source bap_sink bap_source hsp_hs hsp_ag hfp_hf hfp_ag ]
          bluez5.codecs = [ sbc sbc_xq aac ]
          bluez5.enable-sbc-xq = true
          bluez5.hfphsp-backend = "native"
        }
      '')
    ];
    wireplumber.extraConfig.bluetoothEnhancements = {
      "monitor.bluez.properties" = {
        "bluez5.enable-hw-volume" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-sbc-xq" = true;
        "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
      };
    };
  };

  # Bluetooth
  services.blueman.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    corefonts
    nerd-fonts.iosevka
    nerd-fonts.noto
    nerd-fonts.roboto-mono
    nerd-fonts.symbols-only
  ];

  fonts.fontDir.enable = true;
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "Iosevka" ];
      emoji = [ "Noto Color Emoji" ];
      sansSerif = [ "FreeSans" ];
      serif = [ "FreeSerif" ];
    };
  };
}

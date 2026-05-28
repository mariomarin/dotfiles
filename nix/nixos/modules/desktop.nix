{ config, pkgs, lib, ... }:

let
  cfg = config.custom.desktop;

  # Portal packages by desktop type
  portalPackages = {
    gnome = pkgs.xdg-desktop-portal-gnome;
    hyprland = pkgs.xdg-desktop-portal-hyprland;
    leftwm = pkgs.xdg-desktop-portal-gtk;
  };
in
{
  options.custom.desktop = {
    enable = lib.mkEnableOption "desktop environment";

    type = lib.mkOption {
      type = lib.types.enum [ "gnome" "hyprland" "leftwm" ];
      default = "gnome";
      description = "Desktop environment to use";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      # X11 configuration
      xserver = {
        enable = true;
        xkb.layout = "us";
        xkb.variant = "altgr-intl";

        displayManager = lib.mkMerge [
          # Common display manager settings
          {
            sessionCommands = ''
              eval $(${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
              export SSH_AUTH_SOCK

              # Start polkit-gnome authentication agent if not already running
              ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &

              # Set random wallpaper for LeftWM (initial wallpaper)
              # Note: wallpaper rotation is handled by systemd timer
              ${lib.optionalString (cfg.type == "leftwm") ''
                if [ -d "$HOME/.wallpaper" ] && [ "$(ls -A $HOME/.wallpaper 2>/dev/null)" ]; then
                  ${pkgs.feh}/bin/feh --bg-fill --randomize $HOME/.wallpaper/* &
                fi
              ''}
            '';
          }

          # GNOME uses GDM
          (lib.mkIf (cfg.type == "gnome") {
            gdm.enable = true;
          })

          # Other desktops use LightDM
          (lib.mkIf (cfg.type != "gnome") {
            lightdm = {
              enable = true;
              greeters.slick = {
                enable = true;
                theme.name = "Zukitre-dark";
              };
            };
          })
        ];

        windowManager.leftwm.enable = cfg.type == "leftwm";

        desktopManager = {
          xterm.enable = false;
          xfce = lib.mkIf (cfg.type == "leftwm") {
            enable = true;
            noDesktop = true;
            enableXfwm = false;
          };
          gnome.enable = cfg.type == "gnome";
        };

        videoDrivers = [ "modesetting" ];
      };

      # Set the default session for LeftWM
      displayManager.defaultSession = lib.mkIf (cfg.type == "leftwm") "xfce+leftwm";

      # Enable GVFS for file manager support
      gvfs.enable = true;
    };

    programs = {
      # Hyprland (Wayland)
      hyprland.enable = cfg.type == "hyprland";

      # Enable dconf for GTK apps
      dconf.enable = true;
    };

    # Common desktop packages
    environment.systemPackages = with pkgs; [
      gnome-keyring
      libsecret
      polkit_gnome
      xdg-utils
      xdg-user-dirs
    ] ++ (lib.optionals (cfg.type == "leftwm") [
      polybar
      rofi
      picom
      dunst
      feh
      ytfzf
      maim
      xdotool
      transmission_4-gtk
    ]);

    # XDG portal for desktop integration
    xdg.portal = {
      enable = true;
      extraPortals = [ portalPackages.${cfg.type} ];
    };
  };
}

{ config, pkgs, lib, ... }:

let
  isDesktop = config.custom.desktop.enable or false;
in
{
  # Polkit (all machines)
  security.polkit.enable = true;

  # Desktop-specific: GNOME keyring with SSH agent
  security.pam.services = lib.mkIf isDesktop {
    lightdm.enableGnomeKeyring = true;
    login.enableGnomeKeyring = true;
    xfce.enableGnomeKeyring = true;
  };

  services.gnome.gnome-keyring.enable = lib.mkIf isDesktop true;

  # SSH agent configuration
  # Desktop: Use GNOME Keyring (started via desktop.nix sessionCommands)
  # Headless: Use standard SSH agent
  programs.ssh.startAgent = !isDesktop;

  # Desktop-specific: Set proper askpass programs to use gnome-keyring
  environment.variables = lib.mkIf isDesktop {
    SSH_ASKPASS = lib.mkForce "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
    SSH_ASKPASS_REQUIRE = "prefer";
    SUDO_ASKPASS = "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";
  };

  # Local SSL certificate (commented out until certificate exists)
  # security.pki.certificates = [(builtins.readFile ../ssl/certs/localhost.crt)];
}

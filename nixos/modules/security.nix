{ config, pkgs, lib, ... }:

{
  # Polkit
  security.polkit.enable = true;

  # Gnome keyring
  security.pam.services.lightdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  # Local SSL certificate (commented out until certificate exists)
  # security.pki.certificates = [(builtins.readFile ../ssl/certs/localhost.crt)];
}

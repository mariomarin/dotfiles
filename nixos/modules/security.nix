{ config, pkgs, lib, ... }:

{
  # Polkit
  security.polkit.enable = true;

  # Gnome keyring with SSH agent
  security.pam.services.lightdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  # Disable the standard SSH agent since we're using GNOME Keyring
  programs.ssh.startAgent = false;

  # Enable gnome-keyring SSH agent in the session
  # Note: The actual socket path will be set by gnome-keyring-daemon

  # Local SSL certificate (commented out until certificate exists)
  # security.pki.certificates = [(builtins.readFile ../ssl/certs/localhost.crt)];
}

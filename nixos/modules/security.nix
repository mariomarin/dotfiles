{ config, pkgs, lib, ... }:

{
  # Polkit
  security.polkit.enable = true;

  # Gnome keyring
  security.pam.services.lightdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  # SSH Agent
  programs.ssh.startAgent = true;

  # Enable SSH agent in PAM
  security.pam.services.lightdm.startSession = true;

  # Local SSL certificate (commented out until certificate exists)
  # security.pki.certificates = [(builtins.readFile ../ssl/certs/localhost.crt)];
}

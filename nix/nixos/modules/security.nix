_:

{
  security.polkit.enable = true;

  # Headless hosts: standard SSH agent
  programs.ssh.startAgent = true;
}

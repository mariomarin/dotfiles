# Copy nix apps to /Applications for Spotlight and system extension activation
# Workaround for nix-darwin not handling this natively (PR #1396)
{ config, pkgs, lib, ... }:

let
  appEnv = pkgs.buildEnv {
    name = "system-applications";
    paths = config.environment.systemPackages;
    pathsToLink = [ "/Applications" ];
  };
in
{
  system.activationScripts.applications.text = lib.mkForce ''
    echo "setting up /Applications/Nix Apps..." >&2
    targetFolder='/Applications/Nix Apps'
    if [ -L "$targetFolder" ]; then rm "$targetFolder"; fi
    mkdir -p "$targetFolder"
    ${lib.getExe pkgs.rsync} \
      --checksum --copy-unsafe-links --archive --delete \
      --chmod=-w --no-group --no-owner \
      ${appEnv}/Applications/ "$targetFolder"
  '';
}

# axon - Pinterest-managed Mac (darwin-brew → nix-darwin migration)
# Start minimal: only services that need nix-darwin, keep brew for packages
{ config, pkgs, lib, inputs, userConfig, ... }:

let
  username = userConfig.username;
in
{
  imports = [
    ../../modules/xdg-open-svc.nix
  ];

  system.primaryUser = username;
  nixpkgs.config.allowUnfree = true;
  nix.enable = false;

  system.stateVersion = 4;
}

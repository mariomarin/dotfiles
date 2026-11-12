# NixOS development tools module
# Imports shared development tools and adds NixOS-specific options
{ config, pkgs, lib, ... }:

let
  cfg = config.custom.development;
  # Import the shared development packages
  commonDev = import ../../common/modules/development.nix { inherit pkgs lib; };
in
{
  options.custom.development = {
    enable = lib.mkEnableOption "development tools and environment";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = commonDev.environment.systemPackages;
  };
}

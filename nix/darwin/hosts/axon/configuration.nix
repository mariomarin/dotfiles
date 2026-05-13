# axon - work Mac (nix-darwin)
{ config, pkgs, lib, inputs, userConfig, ... }:

let
  username = userConfig.username;
in
{
  imports = [
    ../../../common/modules/cli-tools.nix
    ../../../common/modules/fonts.nix
    ../../../common/modules/tmux.nix
    ../../modules/xdg-open-svc.nix
  ];

  custom.cli = {
    enable = true;
    modernCli = true;
  };

  system.primaryUser = username;
  nixpkgs.config.allowUnfree = true;
  nix.enable = false;

  programs.zsh.enableGlobalCompInit = false;

  system.stateVersion = 4;
}

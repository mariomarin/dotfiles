# Shared CLI tools for both NixOS and nix-darwin
# Provides essential command-line utilities with optional modern replacements
{ config, pkgs, lib, ... }:

let
  cfg = config.custom.cli;
  cliPkgs = import ./cli-tools-pkgs.nix pkgs;
in
{
  options.custom.cli = {
    enable = lib.mkEnableOption "CLI tools";

    modernCli = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include modern CLI replacements (bat, eza, ripgrep, etc.)";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = cliPkgs.base
      ++ lib.optionals cfg.modernCli cliPkgs.modern;

    programs.zsh.enable = true;

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}

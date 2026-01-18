# Tmux installation - plugins managed via TPM and chezmoi
# See ~/.config/tmux/plugins.tmux for plugin configuration
{ pkgs, lib, ... }:

{
  programs.tmux = {
    enable = true;
    # macOS: ensure reattach-to-user-namespace is available for clipboard
    extraConfig = lib.optionalString pkgs.stdenv.isDarwin ''
      set-option -g default-command "${pkgs.reattach-to-user-namespace}/bin/reattach-to-user-namespace -l ${pkgs.zsh}/bin/zsh"
    '';
  };
}

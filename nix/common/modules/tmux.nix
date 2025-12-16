# Shared tmux plugins configuration for NixOS and nix-darwin
# Handles plugin loading and settings via programs.tmux
{ config, pkgs, lib, ... }:

let
  # macOS: set default-command BEFORE sensible plugin runs
  # sensible.tmux sets reattach-to-user-namespace with $SHELL, but $SHELL may be
  # /bin/sh if tmux starts via continuum-boot at login. Pre-setting prevents this.
  darwinDefaultCommand = lib.optionalString pkgs.stdenv.isDarwin ''
    set-option -g default-command "${pkgs.reattach-to-user-namespace}/bin/reattach-to-user-namespace -l ${pkgs.zsh}/bin/zsh"
  '';

  # Plugin packages with their rtp files
  plugins = with pkgs.tmuxPlugins; [
    { pkg = sensible; rtp = "sensible.tmux"; }
    { pkg = yank; rtp = "yank.tmux"; }
    { pkg = resurrect; rtp = "resurrect.tmux"; }
    { pkg = continuum; rtp = "continuum.tmux"; }
    { pkg = tmux-thumbs; rtp = "tmux-thumbs.tmux"; }
    { pkg = tilish; rtp = "tilish.tmux"; }
    { pkg = pkgs.tmux-harpoon; rtp = "harpoon.tmux"; }
    { pkg = fuzzback; rtp = "fuzzback.tmux"; }
    { pkg = extrakto; rtp = "extrakto.tmux"; }
    { pkg = pkgs.unstable.tmuxPlugins."minimal-tmux-status"; rtp = "minimal.tmux"; }
  ];

  # Generate run-shell commands for each plugin
  pluginLoaders = lib.concatMapStringsSep "\n"
    (p:
      "run-shell ${p.pkg}/share/tmux-plugins/*/${p.rtp}"
    )
    plugins;

  # Plugin settings (must come before plugin loading)
  pluginSettings = ''
    # ── Shell configuration ────────────────────────────────────────────
    ${darwinDefaultCommand}
    # ── Plugin settings ─────────────────────────────────────────────────

    # minimal-tmux-status theme
    set -g status-right-length 100
    set -g status-left-length 100
    set -g status-left ""
    set -g @minimal-tmux-bg "#E65050"

    # tmux-resurrect
    set -g @resurrect-strategy-vim 'session'
    set -g @resurrect-strategy-nvim 'session'
    set -g @resurrect-processes '"vim->vim +SLoad" "nvim->nvim"'
    set -g @resurrect-capture-pane-contents 'on'

    # tmux-continuum
    set -g @continuum-restore 'on'
    set -g @continuum-boot 'on'
    set -g @continuum-systemd-start-cmd 'start-server'

    # tmux-thumbs (prefix + F to activate)
    set -g @thumbs-key F

    # tmux-tilish
    set -g @tilish-dmenu 'on'
    set -g @tilish-new_pane '"'
    set -g @tilish-smart-splits 'on'
    set -g @tilish-smart-splits-dirs '= + _ -'
    set -g @tilish-smart-splits-dirs-large ""

    # tmux-harpoon (avoid M-h conflict with tilish)
    set -g @harpoon_key_append1 'C-S-a'
    set -g @harpoon_key_append2 'M-a'

    # ── General settings ────────────────────────────────────────────────

    # For sesh: don't exit tmux when closing a session (switch to another)
    set -g detach-on-destroy off

    # Skip "kill-pane 1? (y/n)" prompt
    bind-key x kill-pane

  '';
in
{
  programs.tmux = {
    enable = true;
    extraConfig = ''
      ${pluginSettings}

      # ── Load plugins ──────────────────────────────────────────────────
      ${pluginLoaders}
    '';
  };
}

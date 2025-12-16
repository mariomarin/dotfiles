# Shared tmux plugins configuration for NixOS and nix-darwin
# Handles plugin loading and settings via programs.tmux
{ config, pkgs, lib, ... }:

let
  # Get the fingers binary path for keybindings
  fingersBin = "${pkgs.tmuxPlugins.fingers}/share/tmux-plugins/tmux-fingers/bin/tmux-fingers";

  # Plugin packages with their rtp files
  plugins = with pkgs.tmuxPlugins; [
    { pkg = sensible; rtp = "sensible.tmux"; }
    { pkg = yank; rtp = "yank.tmux"; }
    { pkg = resurrect; rtp = "resurrect.tmux"; }
    { pkg = continuum; rtp = "continuum.tmux"; }
    { pkg = fingers; rtp = "tmux-fingers.tmux"; }
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

    # tmux-fingers
    set -g @fingers-use-system-clipboard 1
    set -g @fingers-pattern-0 'ssh [a-zA-Z0-9]+:[a-zA-Z0-9+/=]+@[a-zA-Z0-9.-]+'

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

    # ── Custom keybindings ──────────────────────────────────────────────

    # tmux-fingers: Alt+F to start, Alt+J for jump mode
    bind -n M-f run -b "${fingersBin} start #{pane_id}"
    bind -n M-j run -b "${fingersBin} start #{pane_id} --mode jump"
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

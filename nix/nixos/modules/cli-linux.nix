# Linux-specific CLI tools (not available or not needed on macOS)
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.custom.cli.enable {
    environment.systemPackages = with pkgs; [
      # ── Git (full version with extras) ──────────────────────────────────
      gitFull # git gui, gitk, git-send-email (GUI tools need X11)

      # ── Desktop notifications ──────────────────────────────────────────
      libnotify # notify-send (Linux desktop only)

      # ── System info ────────────────────────────────────────────────────
      lfs # List filesystem info (Linux only)

      # ── Shell utilities ───────────────────────────────────────────────
      pipr # Interactive pipe evaluation (uses bubblewrap, Linux only)
    ];
  };
}

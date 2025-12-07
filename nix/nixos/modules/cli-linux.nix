# Linux-specific CLI tools (not available or not needed on macOS)
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.custom.cli.enable {
    environment.systemPackages = with pkgs; [
      # ── Git (full version with extras) ──────────────────────────────────
      gitFull # Overrides common git with full features

      # ── Cloudflare ─────────────────────────────────────────────────────
      cf-vault # Cloudflare credentials management (uses system keyring)

      # ── Desktop notifications ──────────────────────────────────────────
      libnotify # notify-send (Linux desktop only)

      # ── System info ────────────────────────────────────────────────────
      lfs # List filesystem info (Linux only)
    ];
  };
}

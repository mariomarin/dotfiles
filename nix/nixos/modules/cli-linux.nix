# Linux-specific CLI tools (not available or not needed on macOS)
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.custom.cli.enable {
    environment.systemPackages = with pkgs; [
      # ── Git (full version with extras) ──────────────────────────────────
      gitFull # Overrides common git with full features

      # ── Nushell plugins ─────────────────────────────────────────────────
      nushellPlugins.formats # EML, ICS, INI, plist, VCF support
      nushellPlugins.query # Query JSON, XML, web data
      nushellPlugins.gstat # Git status as structured data

      # ── Remote access ───────────────────────────────────────────────────
      cf-vault # Cloudflare credentials management

      # ── System utilities ────────────────────────────────────────────────
      envsubst # Environment variable substitution
      libnotify # Desktop notifications
      libzip # Zip archive library
      viddy # Modern watch command

      # ── Network diagnostics ─────────────────────────────────────────────
      speedtest-cli # Internet speed test
      trippy # Network diagnostic (traceroute + ping)

      # ── Shell utilities ─────────────────────────────────────────────────
      pipr # Interactive pipe evaluation
      lfs # List filesystem info
    ];
  };
}

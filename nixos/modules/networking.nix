{ config, pkgs, lib, ... }:

{
  # Networking configuration - only for non-WSL systems
  # WSL uses Windows networking stack
  config = lib.mkIf (!config.custom.wsl.enable or false) {
    networking.hostName = "nixos";

    networking = {
      nameservers = [ "127.0.0.1" "::1" ];
      networkmanager.enable = true;
      networkmanager.dns = "none";

      firewall = {
        checkReversePath = false;
        allowedTCPPorts = [
          443
          8081
          6443
          19000
          19001
        ];
      };
    };

    # DNS over HTTPS
    services.dnscrypt-proxy2 = {
      enable = true;
      settings = {
        ipv6_servers = true;
        require_dnssec = true;

        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };
      };
    };

    systemd.services.dnscrypt-proxy2.serviceConfig = {
      StateDirectory = "dnscrypt-proxy";
    };

    # Captive portal browser
    programs.captive-browser.enable = true;
    programs.captive-browser.interface = "wlp4s0";
  };
}

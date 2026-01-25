# Harmonia Binary Cache Server
#
# Setup Instructions:
# 1. Generate signing key pair:
#    sudo mkdir -p /var/lib/harmonia
#    sudo nix-store --generate-binary-cache-key <hostname>-1 \
#      /var/lib/harmonia/cache-priv-key.pem \
#      /var/lib/harmonia/cache-pub-key.pem
#
# 2. Set permissions:
#    sudo chown -R harmonia:harmonia /var/lib/harmonia
#    sudo chmod 600 /var/lib/harmonia/cache-priv-key.pem
#    sudo chmod 644 /var/lib/harmonia/cache-pub-key.pem
#
# 3. Client configuration (on machines using this cache):
#    nix.settings = {
#      substituters = [ "http://trident.local:5000" ];
#      trusted-public-keys = [ "<hostname>-1:<contents-of-cache-pub-key.pem>" ];
#    };
#    Or simply enable: localCache.enable = true; (see nix.nix)
#
{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.harmonia;
in
{
  options.harmonia = {
    enable = mkEnableOption "Harmonia binary cache server";

    port = mkOption {
      type = types.port;
      default = 5000;
      description = "Port to bind Harmonia to";
    };

    signKeyPath = mkOption {
      type = types.nullOr types.str;
      default = "/var/lib/harmonia/cache-priv-key.pem";
      description = "Path to the signing key for the binary cache";
    };
  };

  config = mkIf cfg.enable {
    services.harmonia = {
      enable = true;
      signKeyPaths = mkIf (cfg.signKeyPath != null) [ cfg.signKeyPath ];
      settings = {
        bind = "[::]:${toString cfg.port}";
      };
    };

    # Open firewall port for local network access
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}

# Matrix/Synapse server for agent communication
#
# After first deploy, register bot accounts manually:
#   register_new_matrix_user -c /var/lib/matrix-synapse/homeserver.yaml \
#     -u orchestrator-bot -p <password> --admin http://localhost:8008
#   Repeat for each agent that needs a Matrix identity.
#
# Create rooms:
#   - #dev:localhost       — orchestrator listens for dev tasks
#   - #alerts:localhost    — monitor posts deployment health
#   - #admin:localhost     — agent management commands
#
{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.agenticLoop;
in
{
  config = mkIf (cfg.enable && cfg.matrix.enable) {
    services.matrix-synapse = {
      enable = true;
      settings = {
        server_name = cfg.matrix.serverName;
        enable_registration = false;

        listeners = [
          {
            port = cfg.matrix.port;
            bind_addresses = [
              "127.0.0.1"
              "::1"
            ];
            type = "http";
            tls = false;
            resources = [
              {
                names = [
                  "client"
                  "federation"
                ];
                compress = false;
              }
            ];
          }
        ];
      };
    };
  };
}

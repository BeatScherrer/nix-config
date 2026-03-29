# Orchestrator — persistent ZeroClaw daemon connected to Matrix
#
# Runs `zeroclaw daemon` which spawns:
#   - Gateway (HTTP/WebSocket server)
#   - All configured channels (Matrix)
#   - Cron scheduler
#   - Heartbeat worker
#
# HOME is set to the orchestrator's directory so ZeroClaw
# reads ~/.zeroclaw/config.toml and workspace/ from there.
#
{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.agenticLoop;
  envFiles =
    optional (cfg.apiKeys.anthropicKeyFile != null) cfg.apiKeys.anthropicKeyFile
    ++ optional (cfg.apiKeys.openaiKeyFile != null) cfg.apiKeys.openaiKeyFile
    ++ optional (cfg.apiKeys.openrouterKeyFile != null) cfg.apiKeys.openrouterKeyFile
    ++ optional (cfg.apiKeys.matrixTokenFile != null) cfg.apiKeys.matrixTokenFile;
in
{
  config = mkIf (cfg.enable && cfg.agents.orchestrator.enable) {
    systemd.services.agentic-loop-orchestrator = {
      description = "Agentic Loop Orchestrator (ZeroClaw daemon)";
      after = [ "network.target" ] ++ optional cfg.matrix.enable "matrix-synapse.service";
      wants = optional cfg.matrix.enable "matrix-synapse.service";
      wantedBy = [ "multi-user.target" ];

      environment = {
        HOME = "${cfg.workspaceBaseDir}/orchestrator";
        ZEROCLAW_AGENT = "orchestrator";
      };

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = "${cfg.workspaceBaseDir}/orchestrator";
        ExecStart = "${pkgs.zeroclaw}/bin/zeroclaw daemon";
        Restart = "on-failure";
        RestartSec = 10;

        # Load API keys from secret files
        EnvironmentFile = envFiles;

        # Hardening
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.workspaceBaseDir ];
        PrivateTmp = true;
      };
    };
  };
}

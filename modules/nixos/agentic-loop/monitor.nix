# Monitor — persistent ZeroClaw daemon for runtime health watching
#
# Runs as a long-lived daemon watching logs, metrics, and health endpoints.
# Posts alerts to a dedicated Matrix room.
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
  config = mkIf (cfg.enable && cfg.agents.monitor.enable) {
    systemd.services.agentic-loop-monitor = {
      description = "Agentic Loop Monitor (ZeroClaw daemon)";
      after = [ "network.target" ] ++ optional cfg.matrix.enable "matrix-synapse.service";
      wants = optional cfg.matrix.enable "matrix-synapse.service";
      wantedBy = [ "multi-user.target" ];

      environment = {
        HOME = "${cfg.workspaceBaseDir}/monitor";
        ZEROCLAW_AGENT = "monitor";
      };

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = "${cfg.workspaceBaseDir}/monitor";
        ExecStart = "${pkgs.zeroclaw}/bin/zeroclaw daemon";
        Restart = "on-failure";
        RestartSec = 30;

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

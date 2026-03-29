# On-demand agents — invoked by the orchestrator for specific tasks
#
# These are NOT persistent daemons. The orchestrator triggers them via:
#   agentic-invoke-<name> "task description here"
# which sets HOME and runs `zeroclaw agent -m "..."`.
#
# Systemd services are provided for manual invocation and logging:
#   systemctl start agentic-loop-coder@"implement feature X"
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

  onDemandAgents = [
    "planner"
    "coder"
    "reviewer"
    "tester"
    "deployer"
  ];

  enabledOnDemand = filter (name: cfg.agents.${name}.enable) onDemandAgents;

  envFiles =
    optional (cfg.apiKeys.anthropicKeyFile != null) cfg.apiKeys.anthropicKeyFile
    ++ optional (cfg.apiKeys.openaiKeyFile != null) cfg.apiKeys.openaiKeyFile
    ++ optional (cfg.apiKeys.openrouterKeyFile != null) cfg.apiKeys.openrouterKeyFile;

  mkAgentService = name: {
    # Template service: systemctl start agentic-loop-<name>@"message"
    "agentic-loop-${name}@" = {
      description = "Agentic Loop ${name} agent (ZeroClaw) — %i";
      after = [ "network.target" ];

      environment = {
        HOME = "${cfg.workspaceBaseDir}/${name}";
        ZEROCLAW_AGENT = name;
      };

      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = "${cfg.workspaceBaseDir}/${name}";
        ExecStart = "${pkgs.zeroclaw}/bin/zeroclaw agent -m \"%i\"";

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
in
{
  config = mkIf cfg.enable {
    systemd.services = mkMerge (map mkAgentService enabledOnDemand);
  };
}

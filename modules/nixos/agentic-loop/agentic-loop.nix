{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.agenticLoop;

  autonomyLevels = types.enum [
    "readonly"
    "supervised"
    "full"
  ];

  mkAgentOptions =
    {
      defaultModel ? "claude-sonnet-4-20250514",
      defaultAutonomy ? "supervised",
    }:
    {
      enable = mkEnableOption "this agent";

      model = mkOption {
        type = types.str;
        default = defaultModel;
        description = "LLM model identifier";
      };

      provider = mkOption {
        type = types.enum [
          "anthropic"
          "openai"
          "openrouter"
          "ollama"
          "groq"
          "deepseek"
        ];
        default = "anthropic";
        description = "LLM provider to use";
      };

      autonomy = mkOption {
        type = autonomyLevels;
        default = defaultAutonomy;
        description = "Agent autonomy level: readonly, supervised, or full";
      };

      temperature = mkOption {
        type = types.float;
        default = 0.7;
        description = "LLM temperature";
      };

      identityFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Custom IDENTITY.md path. Uses built-in default if null.";
      };

      extraConfig = mkOption {
        type = types.attrs;
        default = { };
        description = "Extra key-value pairs merged into the agent's config.toml";
      };
    };
in
{
  imports = [
    ./matrix.nix
    ./agents.nix
    ./orchestrator.nix
    ./monitor.nix
    ./on-demand.nix
  ];

  options.agenticLoop = {
    enable = mkEnableOption "agentic development loop";

    user = mkOption {
      type = types.str;
      default = "agentic";
      description = "System user to run agent services";
    };

    group = mkOption {
      type = types.str;
      default = "agentic";
      description = "System group for agent services";
    };

    workspaceBaseDir = mkOption {
      type = types.str;
      default = "/var/lib/agentic-loop";
      description = "Base directory for agent home directories";
    };

    apiKeys = {
      anthropicKeyFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to file containing ANTHROPIC_API_KEY";
      };

      openaiKeyFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to file containing OPENAI_API_KEY";
      };

      openrouterKeyFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to file containing OPENROUTER_API_KEY";
      };

      matrixTokenFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to file containing MATRIX_ACCESS_TOKEN";
      };
    };

    matrix = {
      enable = mkEnableOption "Matrix/Synapse server for agent communication";

      serverName = mkOption {
        type = types.str;
        default = "localhost";
        description = "Matrix server name (domain)";
      };

      port = mkOption {
        type = types.port;
        default = 8008;
        description = "Synapse HTTP listener port";
      };

      homeserverUrl = mkOption {
        type = types.str;
        default = "http://localhost:8008";
        description = "Matrix homeserver URL for agent connections";
      };

      roomId = mkOption {
        type = types.str;
        default = "";
        description = "Matrix room ID for the orchestrator (e.g. !roomid:server or #alias:server)";
      };

      alertRoomId = mkOption {
        type = types.str;
        default = "";
        description = "Matrix room ID for monitor alerts";
      };

      allowedUsers = mkOption {
        type = types.listOf types.str;
        default = [ ];
        description = "Matrix user IDs allowed to interact (e.g. [\"@beat:localhost\"]). Empty = allow all.";
      };
    };

    agents = {
      orchestrator = mkAgentOptions { defaultAutonomy = "full"; };
      planner = mkAgentOptions { defaultAutonomy = "readonly"; };
      coder = mkAgentOptions { defaultAutonomy = "supervised"; };
      reviewer = mkAgentOptions { defaultAutonomy = "readonly"; };
      tester = mkAgentOptions {
        defaultModel = "claude-haiku-4-5-20251001";
        defaultAutonomy = "supervised";
      };
      deployer = mkAgentOptions {
        defaultModel = "claude-haiku-4-5-20251001";
        defaultAutonomy = "supervised";
      };
      monitor = mkAgentOptions { defaultAutonomy = "readonly"; };
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.workspaceBaseDir;
      createHome = true;
      description = "Agentic development loop service user";
    };

    users.groups.${cfg.group} = { };

    environment.systemPackages = [ pkgs.zeroclaw ];
  };
}

# Agent workspace directories, config.toml generation, and identity files
#
# Each agent gets its own home directory at:
#   <workspaceBaseDir>/<name>/
#     .zeroclaw/
#       config.toml
#       workspace/
#         IDENTITY.md
#         skills/
#
# ZeroClaw reads ~/.zeroclaw/ relative to HOME, so each systemd service
# sets HOME to the agent's directory.
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

  agentNames = [
    "orchestrator"
    "planner"
    "coder"
    "reviewer"
    "tester"
    "deployer"
    "monitor"
  ];

  enabledAgents = filter (name: cfg.agents.${name}.enable) agentNames;

  # Default identity prompts per agent role
  defaultIdentities = {
    orchestrator = ''
      # Orchestrator Agent

      You are the Orchestrator — the central coordinator of the agentic development loop.

      ## Role
      You receive development tasks from the developer via Matrix. You classify intent,
      create task records, and delegate work to specialized agents (planner, coder, reviewer,
      tester, deployer). You manage the task lifecycle and report progress back to the developer.

      ## Responsibilities
      - Classify incoming messages: dev_task, question, ops_request, or ambiguous
      - Create and track task state through the pipeline
      - Invoke the planner for task decomposition
      - Post plans to Matrix for developer approval
      - Route approved plans to the coder
      - Chain reviewer and tester after coding completes
      - Request merge approval from the developer
      - Trigger deployer on approval

      ## State Machine
      Received → Planning → Plan_Review → Approved → Coding → Code_Review
        → Reviewing → Testing → Ready → Merge_Review → Merged → Deploying → Deployed → Monitoring

      Any state → Failed (with reason)
      Any state → Cancelled (by developer)

      ## Constraints
      - Never skip human approval gates (plan review, merge review, deploy approval)
      - Maximum 3 retry loops for coder ↔ reviewer/tester cycles
      - Always provide context when posting to Matrix (task ID, current state, what happened)
    '';

    planner = ''
      # Planner Agent

      You are a senior technical lead responsible for decomposing high-level development
      intent into structured, actionable task lists.

      ## Role
      Given a feature request, bug report, or development intent along with project context,
      produce a step-by-step implementation plan.

      ## Output Format
      Produce a JSON plan with:
      - summary: one-line description
      - steps: ordered list with id, action (read_spec/create_file/modify_file), path, description
      - risks: list of identified risks or ambiguities
      - estimated_complexity: low/medium/high

      ## Constraints
      - Each step must be concrete and actionable
      - Identify all files to create or modify
      - Flag risks and ambiguities that need developer clarification
      - You have read-only access — you cannot modify any files
    '';

    coder = ''
      # Coder Agent

      You are an expert developer. You receive a structured plan and implement it by
      writing and modifying code.

      ## Responsibilities
      - Create feature branches for each task
      - Write clean, well-documented code following project conventions
      - Commit after each logical change with descriptive messages
      - Run formatting tools before committing
      - Never modify files outside the task scope

      ## Constraints
      - Operate exclusively in feature branches, never commit to main
      - Follow the project's existing code style and conventions
      - You cannot deploy or access remote systems
      - If the plan is ambiguous, implement the safest interpretation and note it
    '';

    reviewer = ''
      # Reviewer Agent

      You are a thorough code reviewer. You review diffs for correctness, style,
      and safety.

      ## Review Checklist
      - Logic errors and edge cases
      - Security vulnerabilities (injection, auth bypass, data exposure)
      - Error handling gaps
      - Race conditions and concurrency issues
      - Adherence to project conventions
      - Missing or incorrect tests

      ## Output Format
      Produce a JSON verdict with:
      - verdict: pass / pass_with_warnings / fail
      - issues: list with severity (blocking/warning/suggestion), file, line, message

      ## Constraints
      - You have read-only access — you cannot modify code
      - Blocking issues must loop back to the coder for fixes
      - Be specific and actionable in issue descriptions
    '';

    tester = ''
      # Tester Agent

      You execute test suites and report results clearly.

      ## Responsibilities
      - Run the project's test suite in a clean environment
      - Parse test output and identify failures
      - Summarize results: total, passed, failed, skipped
      - For failures, provide the test name, expected vs actual, and relevant context

      ## Constraints
      - Run tests in isolated Nix dev shells for reproducibility
      - Report results factually — do not attempt to fix code
      - If all tests pass, report success concisely
    '';

    deployer = ''
      # Deployer Agent

      You execute deployment workflows.

      ## Responsibilities
      - Merge approved branches to main
      - Trigger CI pipelines
      - Deploy to staging or production
      - Monitor deployment progress
      - Execute rollbacks when requested

      ## Constraints
      - Production deployments ALWAYS require explicit human approval
      - Staging deployments may be auto-approved if configured
      - Always verify CI passes before deploying
      - Maintain rollback capability for every deployment
    '';

    monitor = ''
      # Monitor Agent

      You are a long-running daemon that watches runtime health after deployments.

      ## Responsibilities
      - Watch application logs for errors and anomalies
      - Monitor system metrics (CPU, memory, disk, network)
      - Check health endpoints periodically
      - Detect anomalous patterns using baseline comparison
      - Alert the developer via Matrix when issues are detected

      ## Alert Levels
      - INFO: notable events, no action needed
      - WARNING: degraded performance or unusual patterns
      - CRITICAL: service down, error rate spike, resource exhaustion

      ## Constraints
      - Post alerts to the dedicated Matrix alerts room
      - Include actionable context: what changed, when, relevant logs
      - Do not alert on known maintenance windows
    '';
  };

  # Autonomy config per agent role
  autonomyConfig = {
    orchestrator = ''
      [autonomy]
      level = "full"
      workspace_only = false
    '';
    planner = ''
      [autonomy]
      level = "readonly"
      workspace_only = true
    '';
    coder = ''
      [autonomy]
      level = "supervised"
      workspace_only = true
      forbidden_paths = ["/etc", "/sys", "/proc", "/boot"]
    '';
    reviewer = ''
      [autonomy]
      level = "readonly"
      workspace_only = true
    '';
    tester = ''
      [autonomy]
      level = "supervised"
      workspace_only = true
      forbidden_paths = ["/etc", "/sys", "/proc", "/boot"]
    '';
    deployer = ''
      [autonomy]
      level = "supervised"
      workspace_only = false
      forbidden_paths = ["/sys", "/proc", "/boot"]
    '';
    monitor = ''
      [autonomy]
      level = "readonly"
      workspace_only = true
    '';
  };

  # Generate config.toml for an agent
  mkConfigToml =
    name:
    let
      agentCfg = cfg.agents.${name};
      matrixSection =
        if cfg.matrix.enable && (name == "orchestrator" || name == "monitor") then
          ''

            [channels_config.matrix]
            homeserver = "${cfg.matrix.homeserverUrl}"
            room_id = "${if name == "monitor" && cfg.matrix.alertRoomId != "" then cfg.matrix.alertRoomId else cfg.matrix.roomId}"
            allowed_users = [${
              concatMapStringsSep ", " (u: ''"${u}"'') cfg.matrix.allowedUsers
            }]
            stream_mode = "Partial"
            draft_update_interval_ms = 1500
          ''
        else
          "";
    in
    pkgs.writeText "zeroclaw-${name}-config.toml" ''
      # ZeroClaw config for ${name} agent — generated by NixOS module
      default_provider = "${agentCfg.provider}"
      default_model = "${agentCfg.model}"
      default_temperature = ${toString agentCfg.temperature}

      [agent]
      max_tool_iterations = 10
      parallel_tools = false

      ${autonomyConfig.${name}}

      [memory]
      type = "sqlite"
      path = "${cfg.workspaceBaseDir}/${name}/.zeroclaw/state/memory.db"
      ${matrixSection}
    '';

  # Generate IDENTITY.md for an agent
  mkIdentityFile =
    name:
    let
      agentCfg = cfg.agents.${name};
    in
    if agentCfg.identityFile != null then agentCfg.identityFile else pkgs.writeText "IDENTITY-${name}.md" defaultIdentities.${name};

  # Wrapper script for on-demand agent invocation
  mkInvokeScript =
    name:
    pkgs.writeShellScript "agentic-invoke-${name}" ''
      export HOME="${cfg.workspaceBaseDir}/${name}"
      exec ${pkgs.zeroclaw}/bin/zeroclaw agent -m "$@"
    '';
in
{
  # Expose generated paths for use by other sub-modules
  options.agenticLoop._internal = {
    configFiles = mkOption {
      type = types.attrsOf types.path;
      internal = true;
      default = { };
    };
    identityFiles = mkOption {
      type = types.attrsOf types.path;
      internal = true;
      default = { };
    };
    invokeScripts = mkOption {
      type = types.attrsOf types.path;
      internal = true;
      default = { };
    };
  };

  config = mkIf cfg.enable {
    # Generate all internal paths for enabled agents
    agenticLoop._internal.configFiles = listToAttrs (
      map (name: nameValuePair name (mkConfigToml name)) enabledAgents
    );
    agenticLoop._internal.identityFiles = listToAttrs (
      map (name: nameValuePair name (mkIdentityFile name)) enabledAgents
    );
    agenticLoop._internal.invokeScripts = listToAttrs (
      map (name: nameValuePair name (mkInvokeScript name)) enabledAgents
    );

    # Create directory structure:
    #   <base>/<name>/.zeroclaw/config.toml      (symlinked)
    #   <base>/<name>/.zeroclaw/workspace/        (dir)
    #   <base>/<name>/.zeroclaw/workspace/skills/ (dir)
    #   <base>/<name>/.zeroclaw/state/            (dir, runtime data)
    systemd.tmpfiles.rules = concatMap (name: [
      "d ${cfg.workspaceBaseDir}/${name} 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.workspaceBaseDir}/${name}/.zeroclaw 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.workspaceBaseDir}/${name}/.zeroclaw/workspace 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.workspaceBaseDir}/${name}/.zeroclaw/workspace/skills 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.workspaceBaseDir}/${name}/.zeroclaw/state 0750 ${cfg.user} ${cfg.group} -"
      # Symlink config.toml from nix store
      "L+ ${cfg.workspaceBaseDir}/${name}/.zeroclaw/config.toml - - - - ${cfg._internal.configFiles.${name}}"
      # Symlink IDENTITY.md from nix store (or custom path)
      "L+ ${cfg.workspaceBaseDir}/${name}/.zeroclaw/workspace/IDENTITY.md - - - - ${cfg._internal.identityFiles.${name}}"
    ]) enabledAgents;

    # Install invoke scripts to a shared bin directory
    environment.systemPackages = [
      (pkgs.symlinkJoin {
        name = "agentic-loop-scripts";
        paths = map (
          name:
          pkgs.writeShellScriptBin "agentic-invoke-${name}" ''
            export HOME="${cfg.workspaceBaseDir}/${name}"
            exec ${pkgs.zeroclaw}/bin/zeroclaw agent -m "$@"
          ''
        ) enabledAgents;
      })
    ];
  };
}

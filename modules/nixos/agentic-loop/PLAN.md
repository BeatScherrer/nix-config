# Agentic Development Loop — NixOS Module Implementation Plan

Full concept document: [`../../agentic-dev-loop.html`](../../agentic-dev-loop.html)

## Context

Create a NixOS module that sets up an agentic development loop: a system where the developer sends natural language intent via Matrix (Element on phone), and a pipeline of ZeroClaw AI agents (orchestrator, planner, coder, reviewer, tester, deployer, monitor) executes the work, reports progress, and asks for approval at gates.

ZeroClaw is available via `github:numtide/llm-agents.nix` as a Nix package.

---

## ZeroClaw CLI Reference

Key commands used by this module:
- `zeroclaw daemon` — full persistent runtime (gateway + channels + cron + heartbeat)
- `zeroclaw agent -m "message"` — one-shot: process message and exit
- `zeroclaw agent` — interactive REPL

Config: `~/.zeroclaw/config.toml` (TOML). ZeroClaw reads from `$HOME/.zeroclaw/`.
Each agent gets its own HOME directory so it has isolated config and state.

Workspace layout:
```
$HOME/.zeroclaw/
  config.toml                    # provider, model, autonomy, channels
  workspace/
    IDENTITY.md                  # agent role and capabilities
    SOUL.md                      # personality (optional)
    skills/<skill-name>/SKILL.toml
  state/
    memory.db                    # SQLite memory
    matrix/                      # Matrix crypto state (E2EE)
```

Provider env vars: `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `OPENROUTER_API_KEY`

Matrix config section:
```toml
[channels_config.matrix]
homeserver = "http://localhost:8008"
room_id = "!roomid:server"
allowed_users = ["@user:server"]
stream_mode = "Partial"
```

Autonomy levels: `readonly`, `supervised`, `full`

---

## File Structure

```
modules/nixos/agentic-loop/
  PLAN.md              # This file
  agentic-loop.nix     # Main entry, imports sub-modules, defines top-level options
  matrix.nix           # Matrix/Synapse server configuration
  agents.nix           # Workspace dirs, config.toml, identity files, invoke scripts
  orchestrator.nix     # Orchestrator systemd daemon (zeroclaw daemon)
  monitor.nix          # Monitor systemd daemon (zeroclaw daemon)
  on-demand.nix        # On-demand template services (zeroclaw agent -m)
```

## Option Tree

```
agenticLoop.enable
agenticLoop.user                        # default: "agentic"
agenticLoop.group                       # default: "agentic"
agenticLoop.workspaceBaseDir            # default: /var/lib/agentic-loop

agenticLoop.matrix.enable
agenticLoop.matrix.serverName           # e.g. "trident.local"
agenticLoop.matrix.port                 # default: 8008
agenticLoop.matrix.homeserverUrl        # default: "http://localhost:8008"
agenticLoop.matrix.roomId               # orchestrator room
agenticLoop.matrix.alertRoomId          # monitor alerts room
agenticLoop.matrix.allowedUsers         # list of @user:server

agenticLoop.apiKeys.anthropicKeyFile    # path to env file
agenticLoop.apiKeys.openaiKeyFile
agenticLoop.apiKeys.matrixTokenFile

agenticLoop.agents.<name>.enable
agenticLoop.agents.<name>.model         # default: "claude-sonnet-4-20250514"
agenticLoop.agents.<name>.provider      # enum: anthropic, openai, openrouter, ollama, groq, deepseek
agenticLoop.agents.<name>.autonomy      # enum: readonly, supervised, full
agenticLoop.agents.<name>.temperature   # default: 0.7
agenticLoop.agents.<name>.identityFile  # optional custom IDENTITY.md path
agenticLoop.agents.<name>.extraConfig   # passthrough attrs

Agents: orchestrator, planner, coder, reviewer, tester, deployer, monitor
```

## Implementation Steps

### Step 1: `flake.nix` changes
- [x] Add input: `llm-agents`
- [x] Add `llm-agents` to `outputs` destructuring
- [x] Add to `flakePackagesOverlay`: `zeroclaw = llm-agents.packages.${system}.zeroclaw;`

### Step 2: `agentic-loop.nix` — Main module
- [x] Follow `container/container.nix` pattern
- [x] Import sub-modules
- [x] Define `agenticLoop` options namespace with all top-level options
- [x] Helper `mkAgentOptions` with autonomy, temperature, provider enum
- [x] Create system user/group when enabled

### Step 3: `matrix.nix` — Matrix/Synapse
- [x] Guard on `cfg.enable && cfg.matrix.enable`
- [x] Configure `services.matrix-synapse` with local-only listener (127.0.0.1)
- [x] Disable federation for private dev server
- [x] Document manual bot registration step

### Step 4: `agents.nix` — Workspace setup
- [x] Generate `$HOME/.zeroclaw/config.toml` per agent (proper TOML with provider, model, autonomy, Matrix)
- [x] Generate `$HOME/.zeroclaw/workspace/IDENTITY.md` per agent
- [x] `systemd.tmpfiles.rules` for directory structure + symlinks
- [x] `agentic-invoke-<name>` wrapper scripts (sets HOME, runs `zeroclaw agent -m`)

### Step 5: `orchestrator.nix` — Persistent daemon
- [x] `systemd.services.agentic-loop-orchestrator` — `zeroclaw daemon`
- [x] HOME set to agent directory
- [x] After/Wants matrix-synapse.service (if Matrix enabled)
- [x] EnvironmentFile for API keys
- [x] Hardened: NoNewPrivileges, ProtectSystem=strict, ReadWritePaths

### Step 6: `monitor.nix` — Persistent daemon
- [x] Same pattern, `zeroclaw daemon` with monitor HOME
- [x] Matrix alert room configured via config.toml

### Step 7: `on-demand.nix` — Per-task agents
- [x] Template services: `agentic-loop-<name>@.service`
- [x] Invoked via: `systemctl start agentic-loop-coder@"implement feature X"`
- [x] Or via wrapper: `agentic-invoke-coder "implement feature X"`
- [x] Type=oneshot with HOME and hardening

## Host Integration

Add to host `configuration.nix` (e.g. trident):
```nix
imports = [ ../../modules/nixos/agentic-loop/agentic-loop.nix ];

agenticLoop = {
  enable = true;

  matrix.enable = true;
  matrix.serverName = "trident.local";
  matrix.roomId = "#dev:trident.local";
  matrix.alertRoomId = "#alerts:trident.local";
  matrix.allowedUsers = [ "@beat:trident.local" ];

  apiKeys.anthropicKeyFile = "/run/secrets/anthropic-api-key";

  agents = {
    orchestrator.enable = true;
    coder.enable = true;
    # Enable more agents as needed
  };
};
```

## Verification

```bash
# 1. Build without switching
sudo nixos-rebuild build --flake ~/.nix#default

# 2. Test deploy (rollback on reboot)
sudo nixos-rebuild test --flake ~/.nix#default

# 3. Verify workspace layout
ls -la /var/lib/agentic-loop/orchestrator/.zeroclaw/
cat /var/lib/agentic-loop/orchestrator/.zeroclaw/config.toml
cat /var/lib/agentic-loop/orchestrator/.zeroclaw/workspace/IDENTITY.md

# 4. Verify systemd services
systemctl list-unit-files | grep agentic-loop
systemctl status agentic-loop-orchestrator

# 5. Test on-demand invocation
agentic-invoke-coder "hello, are you working?"
# or: systemctl start 'agentic-loop-coder@hello world'

# 6. Matrix (if enabled)
curl http://localhost:8008/_matrix/client/versions
```

## Phased Rollout

- **Phase 1 (now)**: Full module structure implemented. Enable orchestrator + coder. Matrix optional.
- **Phase 2**: Enable planner, reviewer, tester. Wire up orchestrator skills for pipeline.
- **Phase 3**: Add deployer, monitor. Implement approval gates. Custom orchestrator skills.

## Key References

- Full concept & architecture: [`../../agentic-dev-loop.html`](../../agentic-dev-loop.html)
- ZeroClaw repo: `github.com/zeroclaw-labs/zeroclaw`
- ZeroClaw config reference: `github.com/zeroclaw-labs/zeroclaw/wiki/04.1-Configuration-File-Reference`
- Nix package: `github:numtide/llm-agents.nix#zeroclaw`
- Module pattern: `modules/nixos/container/container.nix`
- Service pattern: `modules/nixos/harmonia.nix`

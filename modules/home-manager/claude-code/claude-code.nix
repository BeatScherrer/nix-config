{ pkgs, ... }:
{
  home.packages = with pkgs; [
    claude-code
    claude-code-acp
  ];

  home.sessionVariables = {
    CLAUDE_CODE_ENABLE_TELEMETRY = "0";
  };
}

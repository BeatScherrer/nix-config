{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    claude-code
    claude-code-acp
  ];

  home.sessionVariables = {
    CLAUDE_CODE_ENABLE_TELEMETRY = "0";
  };

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink (config.home.homeDirectory + "/.nix/modules/home-manager/claude-code/CLAUDE.md");
}

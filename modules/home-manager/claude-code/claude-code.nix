{ pkgs, config, ... }:
{
  home.sessionVariables = {
    CLAUDE_CODE_ENABLE_TELEMETRY = "0";
  };

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink (config.home.homeDirectory + "/.nix/modules/home-manager/claude-code/CLAUDE.md");

  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink (config.home.homeDirectory + "/.nix/modules/home-manager/claude-code/settings.json");

  # Global skills directory, tracked in this repo. Out-of-store symlink so
  # skills can be added/edited live without a home-manager rebuild.
  home.file.".claude/skills".source =
    config.lib.file.mkOutOfStoreSymlink (config.home.homeDirectory + "/.nix/modules/home-manager/claude-code/skills");
}

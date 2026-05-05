{ config, ... }:
{
  # Out-of-store symlink so edits to settings.json don't require a rebuild.
  # Pi reads `packages` from settings and auto-installs any missing ones on startup.
  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink
      (config.home.homeDirectory + "/.nix/modules/home-manager/pi/settings.json");

  home.file.".pi/agent/models.json".source =
    config.lib.file.mkOutOfStoreSymlink
      (config.home.homeDirectory + "/.nix/modules/home-manager/pi/models.json");

  # Custom extensions. Out-of-store symlinks so edits don't need a rebuild.
  home.file.".pi/agent/extensions/tavily.ts".source =
    config.lib.file.mkOutOfStoreSymlink
      (config.home.homeDirectory + "/.nix/modules/home-manager/pi/extensions/tavily.ts");

  # Custom themes. Out-of-store symlink so edits hot-reload without a rebuild.
  home.file.".pi/agent/themes/kanagawa.json".source =
    config.lib.file.mkOutOfStoreSymlink
      (config.home.homeDirectory + "/.nix/modules/home-manager/pi/themes/kanagawa.json");
}

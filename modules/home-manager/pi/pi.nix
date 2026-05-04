{ config, ... }:
{
  # Out-of-store symlink so edits to settings.json don't require a rebuild.
  # Pi reads `packages` from settings and auto-installs any missing ones on startup.
  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink
      (config.home.homeDirectory + "/.nix/modules/home-manager/pi/settings.json");
}

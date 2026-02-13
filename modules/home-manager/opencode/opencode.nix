# Install with: bun install -g opencode
{ config, ... }:
{
  xdg.configFile."opencode/opencode.json".source =
    config.lib.file.mkOutOfStoreSymlink
      (config.home.homeDirectory + "/.nix/modules/home-manager/opencode/opencode.json");
}

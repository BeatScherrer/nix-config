{ config, ... }:
{
  home.file.".config/ghostty/config".source =
    config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
    + "/.nix/modules/home-manager/ghostty/config";
}

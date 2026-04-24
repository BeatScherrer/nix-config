{ config, pkgs, ... }:
{
  home.packages = [ pkgs.crush ];

  xdg.configFile."crush/crush.json".source =
    config.lib.file.mkOutOfStoreSymlink
      (config.home.homeDirectory + "/.nix/modules/home-manager/crush/crush.json");
}

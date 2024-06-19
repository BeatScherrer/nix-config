{ config, pkgs, ... }:
{

  xdg.configFile.".local/share/wallpapers".source = ./wallpapers;
}

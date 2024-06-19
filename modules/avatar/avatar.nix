{ config, pkgs, ... }:
{

  xdg.configFile.".local/share/avatars".source = ./avatars;
}

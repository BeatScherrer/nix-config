{ config, pkgs, ... }:
{
  home.file = {
    ".local/share/wallpapers" = {
      enable = true;
      source = ./wallpapers;
      recursive = true;
    };
  };
}

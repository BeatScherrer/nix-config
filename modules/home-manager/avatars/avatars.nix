{ config, pkgs, ... }:
{
  home.file = {
    ".local/share/avatars" = {
      enable = true;
      source = ./avatars;
      recursive = true;
    };
  };
}

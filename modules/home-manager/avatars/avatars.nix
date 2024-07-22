{ config, pkgs, ... }:
{
  home.file = {
    ".local/share/avatars" = {
      enable = true;
      source = ./avatars;
      recursive = true;
    };
  };

  # add the profile picture for gdm
  home.file = {
    ".face" = {
      source = ./avatars/avatar.png;
    };
  };
}

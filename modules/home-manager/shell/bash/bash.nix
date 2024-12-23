{ config, pkgs, ... }:
let
  aliases = import ../aliases.nix;
  bashrc = builtins.readFile ./bashrc;
in
{

  programs = {
    bash = {
      enable = true;
      shellAliases = aliases;
      bashrcExtra = ''
        ${bashrc}
      '';
    };
  };

  home.file.".bashrc_mt".source =
    config.lib.file.mkOutOfStoreSymlink "/home/beat/.nix/modules/home-manager/shell/bash/bashrc_mt";
  # home.file.".bashrc".source =
  #   config.lib.file.mkOutOfStoreSymlink "/home/beat/.nix/modules/home-manager/shell/bash/bashrc";

  home.file = {
    ".oh-my-bash/custom/themes" = {
      source = ./oh-my-bash/themes;
      recursive = true;
    };
  };
}

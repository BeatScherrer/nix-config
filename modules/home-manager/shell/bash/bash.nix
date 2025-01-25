{ config, ... }:
let
  aliases = import ../aliases.nix;
in
{
  programs = {
    bash = {
      enable = true;
      shellAliases = aliases;
      bashrcExtra = ''
        if [[ -f "$HOME/.bashrcExtra" ]]; then
          . $HOME/.bashrcExtra
        fi
        if [[ -f "$HOME/.bashrc_mt" ]]; then
          . $HOME/.bashrc_mt
        fi
      '';
    };
  };

  home.file.".bashrcExtra".source =
    config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
    + "/.nix/modules/home-manager/shell/bash/bashrcExtra";
  home.file.".bashrc_mt".source =
    config.lib.file.mkOutOfStoreSymlink "/home/beat/.nix/modules/home-manager/shell/bash/bashrc_mt";

  home.file = {
    ".oh-my-bash/custom/themes" = {
      source = ./oh-my-bash/themes;
      recursive = true;
    };
  };
}

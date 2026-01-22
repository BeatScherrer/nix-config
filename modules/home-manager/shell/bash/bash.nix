{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  aliases = import ../aliases.nix;
  cfg = config.bash;
in
{
  options.bash = {
    enable = mkEnableOption "bash";
    mkOutOfStoreSymlink = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
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

          . ${pkgs.blesh}/share/blesh/ble.sh

          if [[ -f "$HOME/.bashrcHost" ]]; then
            . $HOME/.bashrcHost
          fi
        '';
      };
    };

    home.file = {
      ".oh-my-bash/custom/themes" = {
        source = ./oh-my-bash/themes;
        recursive = true;
      };
    };

    home.file.".bashrcExtra".source =
      if cfg.mkOutOfStoreSymlink
      then config.lib.file.mkOutOfStoreSymlink (config.home.homeDirectory + "/.nix/modules/home-manager/shell/bash/bashrcExtra")
      else ./bashrcExtra;
    home.file.".bashrc_mt".source =
      if cfg.mkOutOfStoreSymlink
      then config.lib.file.mkOutOfStoreSymlink (config.home.homeDirectory + "/.nix/modules/home-manager/shell/bash/bashrc_mt")
      else ./bashrc_mt;
  };
}

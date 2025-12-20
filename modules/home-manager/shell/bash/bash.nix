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
    enable = mkenableOption "bash";
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
      mkIf (cfg.mkOutOfStoreSymlink) config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
      + "/.nix/modules/home-manager/shell/bash/bashrcExtra";
    home.file.".bashrc_mt".source = mkIf (cfg.mkOutOfStoreSymlink
    ) config.lib.file.mkOutOfStoreSymlink "/home/beat/.nix/modules/home-manager/shell/bash/bashrc_mt";
  };
}

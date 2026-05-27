{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.dms;
in
{
  options.dms = {
    enable = lib.mkEnableOption "DankMaterialShell (dms-shell)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      dms-shell
      brightnessctl
      upower
    ];
  };
}

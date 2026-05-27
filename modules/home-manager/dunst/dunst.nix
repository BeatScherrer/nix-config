{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.dunst;
in
{
  options.dunst = {
    enable = lib.mkEnableOption "dunst notification daemon";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      libnotify
    ];

    services.dunst = {
      enable = true;
      configFile = ./dunstrc2;
    };
  };
}

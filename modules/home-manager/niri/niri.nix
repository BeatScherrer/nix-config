{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.niri;
in
{
  imports = [
    ../noctalia/noctalia.nix
    ../rofi/rofi.nix
    ../dunst/dunst.nix
  ];

  options.niri = {
    enable = mkEnableOption "niri";
  };

  config = mkIf cfg.enable {
    noctalia.enable = true;

    xdg.configFile."niri/config.kdl".source =
      config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
      + "/.nix/modules/home-manager/niri/config.kdl";

    home.packages = with pkgs; [
      wl-clipboard
      grim
      slurp
      playerctl
      brightnessctl
      rofi
      swaynotificationcenter
    ];
  };
}

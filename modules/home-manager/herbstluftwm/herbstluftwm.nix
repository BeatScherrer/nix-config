{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.herbstluftwm;
in
{
  imports = [
    ../polybar/polybar.nix
    ../rofi/rofi.nix
    ../dunst/dunst.nix
  ];

  options.herbstluftwm = {
    enable = mkEnableOption "herbstluftwm";
  };

  config = mkIf cfg.enable {
    polybar.enable = true;

    xdg.configFile."herbstluftwm/autostart".source =
      config.lib.file.mkOutOfStoreSymlink config.home.homeDirectory
      + "/.nix/modules/home-manager/herbstluftwm/autostart";
    xdg.configFile."herbstluftwm/scripts".source = ./scripts;
    xdg.configFile."herbstluftwm/layouts".source = ./layouts;

    home.packages = with pkgs; [
      lxappearance
      dconf
      feh
      picom
      rofi
      playerctl
    ];
  };
}

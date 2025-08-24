{ config, pkgs, ... }:
{
  imports = [
    ../polybar/polybar.nix
    ../rofi/rofi.nix
    ../dunst/dunst.nix
    ../ags/ags.nix
  ];

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
}

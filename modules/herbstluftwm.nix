{ config, pkgs, ...}:
{
  xdg.configFile."herbstluftwm/autostart".source = ./herbstluftwm/autostart;
  xdg.configFile."herbstluftwm/scripts".source = ./herbstluftwm/scripts;
  xdg.configFile."herbstluftwm/layouts".source = ./herbstluftwm/layouts;

  home.packages = with pkgs; [
    dconf
    polybar
    feh
    # picom # NOTE: This kills graphics, try nvidia?
    dunst
    rofi
  ];
}

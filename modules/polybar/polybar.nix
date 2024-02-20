{ config, pkgs, ...}:
{
  xdg.configFile."polybar/config.ini".source = ./config.ini;
  xdg.configFile."polybar/launch.sh".source = ./launch.sh;
  xdg.configFile."polybar/scripts".source = ./scripts;

  home.packages = with pkgs; [
    polybar
    scrot
  ];

}

{ config, pkgs, ... }:
{

  xdg.configFile."rofi/config.rasi".source = ./config.rasi;
  xdg.configFile."rofi/scripts".source = ./scripts;
  xdg.configFile."rofi/themes".source = ./themes;

  home.packages = with pkgs; [ rofi ];
}

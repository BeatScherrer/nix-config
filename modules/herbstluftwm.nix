{ config, pkgs, ...}:
{
  home.file = {
    xdg.configFile."herbstluftwm/autostart".source = ./herbstluftwm/autostart;
  }

}

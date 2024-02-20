{ config, pkgs, ...}:
{
  imports = [
    ../polybar/polybar.nix
  ];

  xdg.configFile."herbstluftwm/autostart".source = ./autostart;
  xdg.configFile."herbstluftwm/scripts".source = ./scripts;
  xdg.configFile."herbstluftwm/layouts".source = ./layouts;

  home.packages = with pkgs; [
    dconf
    feh
    # picom # NOTE: This kills graphics, try nvidia?
    dunst
    rofi
    playerctl
  ];
}

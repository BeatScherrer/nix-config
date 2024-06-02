{ config, pkgs, ... }: {
  imports = [ ../polybar/polybar.nix ];

  xdg.configFile."herbstluftwm/autostart".source = ./autostart;
  xdg.configFile."herbstluftwm/scripts".source = ./scripts;
  xdg.configFile."herbstluftwm/layouts".source = ./layouts;

  home.packages = with pkgs; [
    lxappearance
    dconf
    feh
    picom
    dunst
    rofi
    playerctl
  ];
}

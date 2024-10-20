{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "~/Pictures/walpapers/wallpaper.jpg"
      ];
      wallpaper = [
        "DP-2,~/Pictures/walpapers/wallpaper.jpg"
        "DP-3,~/Pictures/walpapers/wallpaper.jpg"
      ];
    };
  };
}

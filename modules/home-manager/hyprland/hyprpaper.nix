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
        "~/.local/share/wallpapers/wallpaper_plants.jpg"
      ];
      wallpaper = [
        ", ~/.local/share/wallpapers/wallpaper_plants.jpg"
      ];
    };
  };
}

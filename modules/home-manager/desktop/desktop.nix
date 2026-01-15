{
  config,
  lib,
  desktop,
  ...
}:
with lib;
let
  cfg = config.desktop;
in
{
  imports = [
    ../herbstluftwm/herbstluftwm.nix
    ../gnome.nix
    ../hyprland/hyprland.nix
    ../hyprland-noctalia/hyprland-noctalia.nix
    ../niri/niri.nix
  ];

  options.desktop = {
    environment = mkOption {
      type = types.enum [
        "none"
        "herbstluftwm"
        "gnome"
        "niri"
        "hyprland"
        "hyprland-noctalia"
      ];
      default = "none";
      description = "The desktop environment or window manager to use";
    };
  };

  config = {
    desktop.environment = mkDefault desktop;

    herbstluftwm.enable = cfg.environment == "herbstluftwm";
    gnomeHome.enable = cfg.environment == "gnome";
    niri.enable = cfg.environment == "niri";
    hyprlandHome.enable = cfg.environment == "hyprland";
    hyprlandNoctalia.enable = cfg.environment == "hyprland-noctalia";
  };
}

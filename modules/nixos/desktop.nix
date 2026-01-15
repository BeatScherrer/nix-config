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
    ./herbstluftwm.nix
    ./gnome.nix
    ./hyprland.nix
    ./niri.nix
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
    gnome.enable = cfg.environment == "gnome";
    niri.enable = cfg.environment == "niri";
    # Both hyprland variants use the same system-level configuration
    hyprland.enable = cfg.environment == "hyprland" || cfg.environment == "hyprland-noctalia";
  };
}

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
    hyprland.enable = cfg.environment == "hyprland";
  };
}

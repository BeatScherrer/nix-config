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
    ./mango.nix
    ./gpwm.nix
    ./noctalia.nix
    ./dms.nix
  ];

  options.desktop = {
    environment = mkOption {
      type = types.enum [
        "none"
        "herbstluftwm"
        "gnome"
        "niri"
        "mango"
        "hyprland"
        "hyprland-noctalia"
        "gpwm"
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
    mango.enable = cfg.environment == "mango";
    # Both hyprland variants use the same system-level configuration
    hyprland.enable = cfg.environment == "hyprland" || cfg.environment == "hyprland-noctalia";
    gpwm.enable = cfg.environment == "gpwm";
    noctalia.enable =
      cfg.environment == "hyprland-noctalia"
      || cfg.environment == "niri"
      || cfg.environment == "mango"
      || (cfg.environment == "gpwm" && config.gpwm.shell == "noctalia");
    dms.enable = cfg.environment == "gpwm" && config.gpwm.shell == "dms";
  };
}

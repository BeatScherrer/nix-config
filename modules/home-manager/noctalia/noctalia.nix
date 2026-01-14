{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.noctalia;
in
{
  options.noctalia = {
    enable = mkEnableOption "noctalia";
    barDensity = mkOption {
      type = types.enum [
        "compact"
        "normal"
      ];
      default = "compact";
      description = "Bar density setting";
    };
    barPosition = mkOption {
      type = types.enum [
        "top"
        "bottom"
        "left"
        "right"
      ];
      default = "top";
      description = "Bar position on screen";
    };
    colorScheme = mkOption {
      type = types.str;
      default = "monochrome";
      description = "Color scheme for noctalia";
    };
    cornerRadius = mkOption {
      type = types.float;
      default = 0.2;
      description = "Rounded corner ratio";
    };
    widgets = {
      left = mkOption {
        type = types.listOf types.str;
        default = [
          "sidepanel"
          "wifi"
          "bluetooth"
        ];
        description = "Left bar widgets";
      };
      center = mkOption {
        type = types.listOf types.str;
        default = [ "workspaces" ];
        description = "Center bar widgets";
      };
      right = mkOption {
        type = types.listOf types.str;
        default = [
          "battery"
          "clock"
        ];
        description = "Right bar widgets";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      quickshell
      noctalia-shell
      brightnessctl
      gpu-screen-recorder
    ];

    # Noctalia config directory
    xdg.configFile."noctalia/settings.json".text = builtins.toJSON {
      bar = {
        density = cfg.barDensity;
        position = cfg.barPosition;
        widgets = {
          left = cfg.widgets.left;
          center = cfg.widgets.center;
          right = cfg.widgets.right;
        };
      };
      appearance = {
        colorScheme = cfg.colorScheme;
        roundedCornerRatio = cfg.cornerRadius;
      };
      clock = {
        format = "HH:mm";
        showSeconds = false;
      };
    };
  };
}

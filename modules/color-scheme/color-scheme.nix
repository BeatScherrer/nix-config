# What this module should do:
# - Set color schemes with: colorScheme.enable = true;
# - Set color scheme name with: colorScheme.name = "gravel-pit";
# - Provide the color scheme with: colorScheme.scheme;

{ lib, pkgs, config, ...}:
with lib;
let
  cfg = config.colorScheme;
  default_theme = "gravel-pit";
  # TODO:
  assertSchemeKeys = scheme: {
    assertion = lib.lists.all (key: lib.hasAttr key scheme) [
      "background0"
      "background1"
      "background2"

      "foreground0"
      "foreground1"
      "foreground2"

      "color1"
      "color2"
      "color3"
      "color4"
      "color5"
      "color6"

      # black = "000000";
      # white = "ffffff";
      "red"
      "green"
      "blue"
      "yellow"
      "magenta"
      "cyan"

      # TODO: these do not work yet
      # "bright.red"
      # "bright.green"
      # "bright.blue"
      # "bright.yellow"
      # "bright.magenta"
      # "bright.cyan"
    ];
    message = "The color scheme '${cfg.name}' is missing one or more required keys!";
  };
in
{
  imports = [ ];

  options = {
    colorScheme = {
      enable = mkEnableOption "color scheme";
      name = mkOption {
        type = types.str;
        default = "gravel-pit";
        description = "Name of the color scheme as in <name>.nix";
      };
      scheme = mkOption {
        type = types.attrs;
        default = import ./schemes/${default_theme}.nix;
        description = "Scheme definition";
      };
    };
  };

  config = mkIf cfg.enable {
    colorScheme = {
      scheme = import ./schemes/${cfg.name}.nix;
    };

    assertions = [
    (assertSchemeKeys (import ./schemes/${cfg.name}.nix)) 
    (assertSchemeKeys (import ./schemes/${default_theme}.nix)) 
    ];
  };

}

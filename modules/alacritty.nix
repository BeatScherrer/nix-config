{config, lib, pkgs, ...}:
let
  colorScheme = config.colorScheme.palette;
in
{
  # TODO:
  # - [ ] add colors from theme

  programs.alacritty = {
    enable = true;
    settings = {
      window.decorations = "None";
      font = {
        size = 9;
        normal = {
          family = "JetBrainsMonoNL Nerd Font";
          style = "Light";
        };
      };
      colors = with config.colorScheme.colors; {
        primary = {
          background = "0x${colorScheme.base00}";
          bright_foreground = "0x${colorScheme.base07}";
          dim_foreground = "0x${colorScheme.base04}";
          foreground = "0x${colorScheme.base06}";
        };
        normal = {
          black = "0x${colorScheme.base00}";
          blue = "0x${colorScheme.base0D}";
          cyan = "0x${colorScheme.base0C}";
          green = "0x${colorScheme.base0B}";
          magenta = "0x${colorScheme.base0F}";
          red = "0x${colorScheme.base08}";
          white = "0x${colorScheme.base07}";
          yellow = "0x${colorScheme.base0A}";
        };
        # bright = {
        #   black = "#555b65";
        #   blue = "#81a2be";
        #   cyan = "#8abeb7";
        #   green = "#b5bd68";
        #   magenta = "#b294bb";
        #   red = "#cc6666";
        #   white = "#c5c8c6";
        #   yellow = "#ffeac3";
        # };
        cursor = {
          cursor = "CellForeground";
          text = "CellBackground";
        };
      };
    };
  };

}

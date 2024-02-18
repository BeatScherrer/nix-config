{config, lib, pkgs, ...}:
{
  programs.alacritty = {
    enable = true;
    settings = {
      window.decorations = "None";
      font = {
        size = 12;
        normal = {
          family = "JetBrainsMonoNL Nerd Font";
          style = "Light";
        };
      };
      colors = with config.colorScheme.colors; {
        primary = {
          background = "#1d1f21";
          bright_foreground = "#eaeaea";
          dim_foreground = "#828482";
          foreground = "#c5c8c6";
        };
        normal = {
          black = "#282a2e";
          blue = "#5f819d";
          cyan = "#5e8d87";
          green = "#8c9440";
          magenta = "#85678f";
          red = "#a54242";
          white = "#707880";
          yellow = "#de935f";
        };
        bright = {
          black = "#555b65";
          blue = "#81a2be";
          cyan = "#8abeb7";
          green = "#b5bd68";
          magenta = "#b294bb";
          red = "#cc6666";
          white = "#c5c8c6";
          yellow = "#ffeac3";
        };
        cursor = {
          cursor = "CellForeground";
          text = "CellBackground";
        };
      };
    };
  };

}

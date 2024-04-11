{config, lib, pkgs, ...}:
let
  colorScheme = config.colorScheme.scheme;
in
{
  home.packages = with pkgs; [
    alacritty
  ];

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
          background = "0x${colorScheme.background0}";
          dim_foreground = "0x${colorScheme.background1}";
          foreground = "0x${colorScheme.foreground0}";
          bright_foreground = "0x${colorScheme.foreground0}";
        };
        normal = {
          # black = "0x${colorScheme.black}";
          # white = "0x${colorScheme.white}";
          red = "0x${colorScheme.red}";
          green = "0x${colorScheme.green}";
          blue = "0x${colorScheme.blue}";
          yellow = "0x${colorScheme.yellow}";
          magenta = "0x${colorScheme.magenta}";
          cyan = "0x${colorScheme.cyan}";
        };
        bright = {
          # black = "#555b65";
          # white = "#c5c8c6";
          # TODO:
          # red = "0x${colorScheme.bright.red}";
          # green = "0x${colorScheme.bright.green}";
          # blue = "0x${colorScheme.bright.blue}";
          # yellow = "0x${colorScheme.bright.yellow}";
          # magenta = "0x${colorScheme.bright.magenta}";
          # cyan = "0x${colorScheme.bright.cyan}";
        };
        cursor = {
          cursor = "CellForeground";
          text = "CellBackground";
        };
      };
    };
  };

}

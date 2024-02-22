{ config, pkgs, ...}:
{
  # xdg.configFile."polybar/config.ini".source = ./config.ini;
  # xdg.configFile."polybar/launch.sh".source = ./launch.sh;
  xdg.configFile."polybar/scripts".source = ./scripts;

  home.packages = with pkgs; [
    polybar
    scrot
  ];

  # TODO: Use colors from color scheme

  services.polybar = {
    enable = true;
    script = "polybar main &";

    settings = {
      "global/wm" = {
        margin-bottom = 0;
        margin-top = 0;

      "bar/base" = {
        font-0 = "Inconsolata for Powerline:size=16;4";
        font-1 = "Font Awesome 6 Pro:style=Light:size=14;4";
        font-2 = "Font Awesome 6 Brands:size=28;4";

        override-redirect = true;
        monitor-strict = false;
        bottom = false;
        fixed-center = true;

        # Dimension defined as pixel value (e.g. 35) or percentage (e.g. 50%),
        # the percentage can optionally be extended with a pixel offset like so:
        # 50%:-10, this will result in a width or height of 50% minus 10 pixels
        width = "40%";
        height = 40;

        # Offset defined as pixel value (e.g. 35) or percentage (e.g. 50%)
        # the percentage can optionally be extended with a pixel offset like so:
        # 50%:-10, this will result in an offset in the x or y direction
        # of 50% minus 10 pixels
        offset-x = "30%";
        offset-y = "1%";

        foreground = "${config.colorScheme.palette.base05}";
        background = "${config.colorScheme.palette.base03}";

        radius-top = 0.0;
        radius-bottom = 0.0;

        padding = 0;

        module-margin-left = 0;
        module-margin-right = 0;

        dim-value = 1.0;
      };

      "bar/main" = {
        "inherit" = "bar/base";
        monitor = "eDP-1-1";
        monitor-fallback = "eDP-1";
      };

        # modules-left = launcher i3 sep
        modules-left = "launcher info-hlwm-workspaces sep";
        modules-center = "date song";
        modules-right = "colors sep scrot sep alsa bluetooth sep network nordvpn sep memory cpu sep powermenu sep";

        # The separator will be inserted between the output of each module
        separator = " ";

        # Available positions:
        #   left
        #   center
        #   right
        #   none
        tray-position = "right";

        # If true, the bar will not shift its
        # contents when the tray changes
        tray-detached = false;

        # Tray icon max size
        tray-maxsize = 16;

        # Background color for the tray container
        # ARGB color (e.g. #f00, #ff992a, #ddff1023)
        # By default the tray container will use the bar
        # background color.
        # tray-background = "${colors.background}"; TODO:

        # Tray offset defined as pixel value (e.g. 35) or percentage (e.g. 50%)
        tray-offset-x = 0;
        tray-offset-y = 0;

        # Pad the sides of each tray icon
        tray-padding = 5;

        # Scale factor for tray clients
        tray-scale = 1.0;

        enable-ipc = true;
      };

      colors = {
        # TODO:
        # background = "${xrdb:background}";
        # background-alt = "${xrdb:color0}";
        # foreground = "${xrdb:foreground}";
        # foreground-alt = "${xrdb:color15}";
        # black = "${xrdb:color20}";
        # red = "${xrdb:color1}";
        # green = "${xrdb:color2}";
        # yellow = "${xrdb:color3}";
        # blue = "${xrdb:color4}";
        # magenta = "${xrdb:color5}";
        # cyan = "${xrdb:color6}";
        # white = "${xrdb:color7}";
        # alpha = "#00000000";
      };

      "module/volume" = {
        type = "internal/pulseaudio";
        format.volume = "<ramp-volume> <label-volume>";
        label.muted.text = "🔇";
        label.muted.foreground = "#666";
        ramp.volume = ["🔈" "🔉" "🔊"];
        click.right = "pavucontrol &";
      };
    };
  };

}

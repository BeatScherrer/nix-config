# TODO:
# - [ ] add options for bar height and font size
# - [ ] make volume module work with pipewire

{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  colorScheme = config.colorScheme.scheme;
  cfg = config.polybar;
in
{
  options.polybar = {
    enable = mkEnableOption "polybar";
    mainMonitor = mkOption { type = types.str; };
    fallbackMonitor = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    # xdg.configFile."polybar/config.ini".source = ./config.ini;
    # xdg.configFile."polybar/launch.sh".source = ./launch.sh;
    xdg.configFile."polybar/scripts".source = ./scripts;

    # NOTE: Fix polybar service env
    systemd.user.services.polybar = {
      Service.Environment = lib.mkForce ""; # to override the package's default configuration
      Service.PassEnvironment = "PATH"; # so that the entire PATH is passed to this service (alternatively, you can import the entire PATH to systemd at startup, which I'm not sure is recommended
      Install.WantedBy = [ "graphical-session.target" ];
    };

    home.packages = with pkgs; [ scrot ];

    services.polybar = {
      enable = true;
      script = "~/.config/polybar/scripts/launch_polybar.sh";
      package = pkgs.polybar.override {
        mpdSupport = true;
        pulseSupport = true;
      };

      settings = {
        "global/wm" = {
          margin-bottom = 0;
          margin-top = 0;
        };

        "bar/base" = {
          font-0 = "Inconsolata for Powerline:size=18;4";
          # TODO: Add font awseom pro smh
          font-1 = "Font Awesome 6 Pro:style=Light:size=18;4";
          font-2 = "Font Awesome 6 Brands:size=32;4";

          override-redirect = true;
          monitor-strict = false;
          bottom = false;
          fixed-center = true;

          # Dimension defined as pixel value (e.g. 35) or percentage (e.g. 50%),
          # the percentage can optionally be extended with a pixel offset like so:
          # 50%:-10, this will result in a width or height of 50% minus 10 pixels
          width = "50%";
          height = 60;

          # Offset defined as pixel value (e.g. 35) or percentage (e.g. 50%)
          # the percentage can optionally be extended with a pixel offset like so:
          # 50%:-10, this will result in an offset in the x or y direction
          # of 50% minus 10 pixels
          offset-x = "25%";
          offset-y = 5;

          foreground = "${colorScheme.foreground0}";
          background = "#00000000";

          radius-top = 0.0;
          radius-bottom = 0.0;

          padding = 0;

          module-margin-left = 0;
          module-margin-right = 0;

          dim-value = 1.0;
        };

        "bar/main" = {
          "inherit" = "bar/base";
          monitor = cfg.mainMonitor;
          monitor-fallback = cfg.fallbackMonitor;

          # modules-left = launcher i3 sep
          modules-left = "launcher info-hlwm-workspaces sep";
          modules-center = "date song";
          modules-right = "scrot sep volume bluetooth sep network sep memory temperature coolant cpu sep battery powermenu sep";

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
          tray-maxsize = 32;

          # Background color for the tray container
          # ARGB color (e.g. #f00, #ff992a, #ddff1023)
          # By default the tray container will use the bar
          # background color.
          tray-background = "${colorScheme.background0}";

          # Tray offset defined as pixel value (e.g. 35) or percentage (e.g. 50%)
          tray-offset-x = 0;
          tray-offset-y = 0;

          # Pad the sides of each tray icon
          tray-padding = 5;

          # Scale factor for tray clients
          tray-scale = 1.0;

          enable-ipc = true;
        };

        # _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_
        #
        #	    __  ___          __      __
        #	   /  |/  /___  ____/ /_  __/ /__  _____
        #	  / /|_/ / __ \/ __  / / / / / _ \/ ___/
        #	 / /  / / /_/ / /_/ / /_/ / /  __(__  )
        #	/_/  /_/\____/\__,_/\__,_/_/\___/____/
        #
        # Created By Aditya Shakya @adi1090x
        #
        # _-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

        "module/volume" = {
          type = "internal/pulseaudio";

          format-volume = "<ramp-volume> <label-volume>";
          format-volume-background = "${colorScheme.background0}";
          format-volume-foreground = "${colorScheme.foreground0}";
          format-volume-padding = 2;

          label-volume = "%percentage%%";

          format-muted-prefix = "  ";
          format-muted-background = "${colorScheme.background0}";
          format-muted-foreground = "${colorScheme.foreground0}";
          format-muted-padding = 2;

          ramp-volume-0 = "";
          ramp-volume-1 = "";
          ramp-volume-2 = "";
          ramp-volume-3 = "";
          ramp-volume-4 = "";

          ramp-headphones-0 = "";
          ramp-headphones-1 = "";
        };

        "module/battery" = {
          type = "internal/battery";

          full-at = "99";
          # Use the following command to list batteries and adapters:
          # $ ls -1 /sys/class/power_supply/
          battery = "BAT0";
          adapter = "AC";
          poll-interval = 2;
          time-format = "%H:%M";

          format-charging = "<animation-charging> <label-charging>";
          format-charging-background = "${colorScheme.background0}";
          format-charging-foreground = "${colorScheme.foreground0}";
          format-charging-padding = 2;

          format-discharging = "<ramp-capacity> <label-discharging>";
          format-discharging-background = "${colorScheme.background0}";
          format-discharging-foreground = "${colorScheme.foreground0}";
          format-discharging-padding = 2;

          format-full = "<label-full>";
          format-full-background = "${colorScheme.background0}";
          format-full-foreground = "${colorScheme.foreground0}";
          format-full-padding = 2;

          label-charging = "%percentage%%";
          label-discharging = "%percentage%%";
          label-full = "100% Charged";

          # Only applies if <ramp-capacity> is used
          ramp-capacity-0 = "";
          ramp-capacity-1 = "";
          ramp-capacity-2 = "";
          ramp-capacity-3 = "";
          ramp-capacity-4 = "";
          ramp-capacity-5 = "";
          ramp-capacity-6 = "";
          ramp-capacity-7 = "";
          ramp-capacity-8 = "";
          ramp-capacity-9 = "";

          # Only applies if <animation-charging> is used
          animation-charging-0 = "";
          animation-charging-1 = "";
          animation-charging-2 = "";
          animation-charging-3 = "";

          # Framerate in milliseconds
          animation-charging-framerate = 750;
        };

        "module/cpu" = {
          type = "internal/cpu";

          interval = "0.5";

          format = "<label>";
          format-prefix = "CPU";
          format-background = "${colorScheme.background0}";
          format-foreground = "${colorScheme.foreground0}";
          format-padding = 2;

          label = " %percentage%%";
        };

        "module/date" = {
          type = "internal/date";

          interval = "1.0";

          time = " %H:%M";
          time-alt = " %d.%m.%Y%";

          format = "<label>";
          format-background = "${colorScheme.background0}";
          format-foreground = "${colorScheme.foreground0}";
          format-padding = 2;

          label = "%time%";
        };

        "module/memory" = {
          type = "internal/memory";

          interval = 3;

          format = "<label>";
          format-prefix = "RAM";
          format-background = "${colorScheme.background0}";
          format-foreground = "${colorScheme.foreground0}";
          format-padding = 2;

          label = " %mb_used%";
        };

        "module/mpd" = {
          type = "internal/mpd";

          interval = 2;

          format-online = "<label-song>";
          format-online-background = "${colorScheme.background0}";
          format-online-foreground = "${colorScheme.foreground0}";
          format-online-padding = 2;

          label-song = "%artist% - %title%";
          label-song-maxlen = 30;
          label-song-ellipsis = true;

          label-offline = "MPD is offline";
        };

        "module/mpd_i" = {
          type = "internal/mpd";

          interval = 2;

          format-online = "<icon-prev> <toggle> <icon-next>";
          format-online-background = "${colorScheme.background0}";
          format-online-foreground = "${colorScheme.foreground0}";
          format-online-padding = 2;

          label-offline = "MPD is offline";

          # Only applies if <icon-X> is used
          icon-play = "";
          icon-pause = "";
          icon-stop = "";
          icon-prev = "";
          icon-next = "";
        };

        "module/network" = {
          type = "internal/network";
          interface = "eno1"; # TODO: make configurable with options

          interval = "1.0";
          accumulate-stats = true;
          unknown-as-up = true;

          format-connected = "<ramp-signal> <label-connected>";
          format-connected-background = "${colorScheme.background0}";
          format-connected-foreground = "${colorScheme.foreground0}";
          format-connected-padding = 2;

          format-disconnected = "<label-disconnected>";
          format-disconnected-background = "${colorScheme.background0}";
          format-disconnected-foreground = "${colorScheme.foreground0}";
          format-disconnected-padding = 2;

          label-connected = "%local_ip% %ifname% %downspeed:7% %upspeed:7%";
          label-disconnected = "";

          # Only applies if <ramp-signal> is used
          ramp-signal-0 = "";
          ramp-signal-1 = "";
          ramp-signal-2 = "";
          ramp-signal-3 = "";
          ramp-signal-4 = "";
        };

        "module/workspaces" = {
          type = "internal/xworkspaces";

          pin-workspaces = true;

          enable-click = true;
          enable-scroll = true;

          format = "<label-state>";
          format-padding = 0;

          label-monitor = "%name%";

          label-active = "%name%";
          label-active-background = "${colorScheme.red}";
          label-active-foreground = "${colorScheme.background1}";

          label-occupied = "%icon%";
          label-occupied-underline = "${colorScheme.background1}";

          label-urgent = "%icon%";
          label-urgent-foreground = "${colorScheme.background0}";
          label-urgent-background = "${colorScheme.red}";

          label-empty = "%name%";
          label-empty-background = "${colorScheme.background0}";
          label-empty-foreground = "${colorScheme.background1}";

          label-active-padding = 2;
          label-urgent-padding = 2;
          label-occupied-padding = 2;
          label-empty-padding = 2;
        };

        "module/i3" = {
          type = "internal/i3";

          # ws-icon-[0-9]+ = "<label>;<icon>";
          # NOTE: The <label> needs to match the name of the i3 workspace
          # Neither <label> nor <icon> can contain a semicolon (;)
          ws-icon-0 = "1;♚";
          ws-icon-1 = "2;♛";
          ws-icon-2 = "3;♜";
          ws-icon-3 = "4;♝";
          ws-icon-4 = "5;♞";
          ws-icon-default = "♟";
          # NOTE: You cannot skip icons, e.g. to get a ws-icon-6
          # you must also define a ws-icon-5.
          # NOTE: Icon will be available as the %icon% token inside label-*

          # Available tags:
          #   <label-state> (default) - gets replaced with <label-(focused|unfocused|visible|urgent)>
          #   <label-mode> (default)
          format = "<label-state> <label-mode>";

          # Available tokens:
          #   %mode%
          # Default: %mode%
          label-mode = "%mode%";
          label-mode-padding = 2;
          label-mode-background = "#e60053";

          # Available tokens:
          #   %name%
          #   %icon%
          #   %index%
          #   %output%
          # Default: %icon% %name%
          label-focused = "%index%";
          label-focused-foreground = "${colorScheme.background0}";
          label-focused-background = "${colorScheme.foreground0}";
          label-focused-underline = "${colorScheme.foreground0}";
          label-focused-padding = 2;

          # Available tokens:
          #   %name%
          #   %icon%
          #   %index%
          #   %output%
          # Default: %icon% %name%
          label-unfocused = "%index%";
          label-unfocused-foreground = "${colorScheme.background1}";
          label-unfocused-background = "${colorScheme.background0}";
          label-unfocused-padding = 2;

          # Available tokens:
          #   %name%
          #   %icon%
          #   %index%
          #   %output%
          # Default: %icon% %name%
          label-visible = "%index%";
          label-visible-foreground = "${colorScheme.background1}";
          label-visible-background = "${colorScheme.background0}";
          label-visible-padding = 2;

          # Available tokens:
          #   %name%
          #   %icon%
          #   %index%
          #   %output%
          # Default: %icon% %name%
          label-urgent = "%index%";
          label-urgent-foreground = "#000000";
          label-urgent-background = "#bd2c40";
          label-urgent-padding = 2;

          # Separator in between workspaces
          label-separator = "";
          label-separator-padding = 1;
          label-separator-background = "${colorScheme.background0}";
          label-separator-foreground = "${colorScheme.background1}";

          # Only show workspaces defined on the same output as the bar
          #
          # Useful if you want to show monitor specific workspaces
          # on different bars
          #
          # Default: false
          pin-workspaces = true;

          # Show urgent workspaces regardless of whether the workspace is actually hidden
          # by pin-workspaces.
          #
          # Default: false
          # New in version 3.6.0
          show-urgent = true;

          # This will split the workspace name on ':'
          # Default: false
          strip-wsnumbers = true;

          # Sort the workspaces by index instead of the default
          # sorting that groups the workspaces by output
          # Default: false
          index-sort = true;

          # Create click handler used to focus workspace
          # Default: true
          enable-click = true;

          # Create scroll handlers used to cycle workspaces
          # Default: true
          enable-scroll = false;

          # Wrap around when reaching the first/last workspace
          # Default: true
          wrapping-scroll = false;

          # Set the scroll cycle direction
          # Default: true
          reverse-scroll = false;

          # Use fuzzy (partial) matching on labels when assigning
          # icons to workspaces
          # Example: code;♚ will apply the icon to all workspaces
          # containing 'code' in the label
          # Default: false
          fuzzy-match = true;
        };

        "module/temperature" = {
          type = "internal/temperature";

          format-background = "${colorScheme.background0}";
          format-padding = 2;

          # Seconds to sleep between updates
          # Default: 1
          interval = 0.5;

          # Thermal zone to use
          # To list all the zone types, run
          # $ for i in /sys/class/thermal/thermal_zone*; do echo "$i: $(<$i/type)"; done
          # Default: 0
          thermal-zone = 0;

          # Full path of temperature sysfs path
          # Use `sensors` to find preferred temperature source, then run
          # $ for i in /sys/class/hwmon/hwmon*/temp*_input; do echo "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*})) $(readlink -f $i)"; done
          # to find path to desired file
          # Default reverts to thermal zone setting
          hwmon-path = "/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon1/temp1_input";

          # Base temperature for where to start the ramp (in degrees celsius)
          # Default: 0
          base-temperature = 20;

          # Threshold temperature to display warning label (in degrees celsius)
          # Default: 80
          warn-temperature = 80;
        };

        "module/sep" = {
          type = "custom/text";
          content = "| ";

          content-background = "#00000000";
          content-foreground = "#00000000";
          content-padding = 0;
        };

        # "module/colors" = {
        # type = custom/text
        # content = 
        # content-background = #FFFFFF
        # content-foreground = #CC6666
        # content-padding = 2
        # click-left = ~/.config/polybar/scripts/colors_rofi.sh &
        # };

        "module/song" = {
          type = "custom/script";
          interval = 1;
          format = " <label>";
          format-background = "${colorScheme.foreground0}";
          format-foreground = "${colorScheme.background0}";
          format-padding = 2;
          exec = "~/.config/polybar/scripts/get_song.sh";
        };

        "module/launcher" = {
          type = "custom/text";
          content = "";
          content-background = "${colorScheme.background0}";
          content-foreground = "${colorScheme.foreground0}";
          content-padding = 2;
          click-left = "sh ~/.scripts/rofi_launcher.sh";
        };

        "module/bluetooth" = {
          type = "custom/script";
          interval = 1;
          format-background = "${colorScheme.background0}";
          format-foreground = "${colorScheme.foreground0}";
          format-padding = 2;
          exec = "~/.config/polybar/scripts/bluetooth.sh";
        };

        "module/scrot" = {
          type = "custom/text";
          content = "";
          content-background = "${colorScheme.background0}";
          content-foreground = "${colorScheme.foreground0}";
          content-padding = 2;
          click-left = "~/.config/polybar/scripts/scrot.sh";
        };

        "module/coolant" = {
          type = "custom/script";
          interval = 1;
          format = " <label>";
          format-background = "${colorScheme.background0}";
          format-foreground = "${colorScheme.foreground0}";
          format-padding = 2;
          exec = "~/.config/polybar/scripts/coolant.sh";
        };

        "module/powermenu" = {
          type = "custom/text";
          content = "";
          content-background = "${colorScheme.background0}";
          content-foreground = "${colorScheme.foreground0}";
          content-padding = 2;
          click-left = "rofi -show power-menu -modi power-menu:~/.config/rofi/scripts/rofi-power-menu -theme ~/.config/rofi/themes/beat.rasi";
        };

        "module/info-hlwm-workspaces" = {
          type = "custom/script";
          exec = "$HOME/.config/polybar/scripts/info-hlwm-workspaces.sh";
          tail = true;
          scroll-up = "herbstclient use_index -1 --skip-visible &";
          scroll-down = "herbstclient use_index +1 --skip-visible &";
          label-active-font = 1;
        };
      };
    };

  };

}

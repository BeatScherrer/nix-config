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
      };

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
        # tray-background = "${config.colorScheme.palette.base00}"; TODO:

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
        format.volume = "<ramp-volume> <label-volume>";
        label.muted.text = "🔇";
        label.muted.foreground = "#666";
        ramp.volume = ["🔈" "🔉" "🔊"];
        click.right = "pavucontrol &";
      };


"module/alsa" = {

type = "internal/pulseaudio";

format-volume = "<ramp-volume> <label-volume>";
format-volume-background = "${config.colorScheme.palette.base00}";
format-volume-foreground = "${config.colorScheme.palette.base01}";
format-volume-padding = 2;

label-volume = "%percentage%%";

format-muted-prefix = "  ";
format-muted-background = "${config.colorScheme.palette.base00}";
format-muted-foreground = "${config.colorScheme.palette.base01}";
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
battery = "BAT1";
adapter = "ACAD";
poll-interval = 2;
time-format = "%H:%M";

format-charging = "<animation-charging> <label-charging>";
format-charging-background = "${config.colorScheme.palette.base00}";
format-charging-foreground = "${config.colorScheme.palette.base01}";
format-charging-padding = 2;

format-discharging = "<ramp-capacity> <label-discharging>";
format-discharging-background = "${config.colorScheme.palette.base00}";
format-discharging-foreground = "${config.colorScheme.palette.base01}";
format-discharging-padding = 2;

format-full = "<label-full>";
format-full-background = "${config.colorScheme.palette.base00}";
format-full-foreground = "${config.colorScheme.palette.base01}";
format-full-padding = 2;

label-charging = "%percentage%%";
label-discharging = "%percentage%%";
label-full = "100% Charged";

# Only applies if <ramp-capacity> is used
ramp-capacity-0 = "";
ramp-capacity-1 = "";
ramp-capacity-2 = "";
ramp-capacity-3 = "";
ramp-capacity-4 = "";
ramp-capacity-5 = "";
ramp-capacity-6 = "";
ramp-capacity-7 = "";
ramp-capacity-8 = "";
ramp-capacity-9 = "";

# Only applies if <animation-charging> is used
animation-charging-0 = "";
animation-charging-1 = "";
animation-charging-2 = "";
animation-charging-3 = "";

# Framerate in milliseconds
animation-charging-framerate = 750;
};


"module/cpu" = {
type = "internal/cpu";

interval = "0.5";

format = "<label>";
format-prefix = "CPU";
format-background = "${config.colorScheme.palette.base00}";
format-foreground = "${config.colorScheme.palette.base01}";
format-padding = 2;

label = " %percentage%%";
};

"module/date" = {
type = "internal/date";

interval = "1.0";

time = " %H:%M";
time-alt = " %d.%m.%Y%";

format = "<label>";
format-background = "${config.colorScheme.palette.base00}";
format-foreground = "${config.colorScheme.palette.base01}";
format-padding = 2;

label = "%time%";
};

"module/memory" = {
type = "internal/memory";

interval = 3;

format = "<label>";
format-prefix = "RAM";
format-background = "${config.colorScheme.palette.base00}";
format-foreground = "${config.colorScheme.palette.base01}";
format-padding = 2;

label = " %mb_used%";
};

"module/mpd" = {
type = "internal/mpd";

interval = 2;

format-online = "<label-song>";
format-online-background = "${config.colorScheme.palette.base00}";
format-online-foreground = "${config.colorScheme.palette.base01}";
format-online-padding = 2;

label-song =  "%artist% - %title%";
label-song-maxlen = 30;
label-song-ellipsis = true;

label-offline = "MPD is offline";
};

"module/mpd_i" = {
type = "internal/mpd";

interval = 2;

format-online = "<icon-prev> <toggle> <icon-next>";
format-online-background = "${config.colorScheme.palette.base00}";
format-online-foreground = "${config.colorScheme.palette.base01}";
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
interface = "enp4s0";

interval = "1.0";
accumulate-stats = true;
unknown-as-up = true;

format-connected = "<ramp-signal> <label-connected>";
format-connected-background = "${config.colorScheme.palette.base00}";
format-connected-foreground = "${config.colorScheme.palette.base01}";
format-connected-padding = 2;

format-disconnected = "<label-disconnected>";
format-disconnected-background = "${config.colorScheme.palette.base00}";
format-disconnected-foreground = "${config.colorScheme.palette.base01}";
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
# label-active-background = "${colors.red}"; # TODO:
label-active-foreground = "${config.colorScheme.palette.base01}";

label-occupied = "%icon%";
label-occupied-underline = "${config.colorScheme.palette.base01}";

label-urgent = "%icon%";
# label-urgent-foreground = "${colors.red}"; TODO:
# label-urgent-background = "${colors.red}"; TODO:

label-empty = "%name%";
label-empty-background = "${config.colorScheme.palette.base00}";
label-empty-foreground = "${config.colorScheme.palette.base01}";

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
label-focused-foreground = "${config.colorScheme.palette.base00}";
# label-focused-background = "${colors.yellow}"; TODO:
label-focused-underline = "${config.colorScheme.palette.base01}";
label-focused-padding = 2;

# Available tokens:
#   %name%
#   %icon%
#   %index%
#   %output%
# Default: %icon% %name%
label-unfocused = "%index%";
label-unfocused-foreground = "${config.colorScheme.palette.base01}";
label-unfocused-background = "${config.colorScheme.palette.base00}";
label-unfocused-padding = 2;

# Available tokens:
#   %name%
#   %icon%
#   %index%
#   %output%
# Default: %icon% %name%
label-visible = "%index%";
label-visible-foreground = "${config.colorScheme.palette.base01}";
label-visible-background = "${config.colorScheme.palette.base00}";
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
label-separator-background = "${config.colorScheme.palette.base00}";
label-separator-foreground = "${config.colorScheme.palette.base01}";

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

format-background = "${config.colorScheme.palette.base00}";
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

# content-background = "${colors.alpha}"; TODO:
# content-foreground = "${colors.alpha}"; TODO:
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
format-background = "#999";
format-foreground = "#000";
format-padding = 2;
exec = "~/.config/polybar/scripts/get_song.sh";
};

# [module/launcher]
# type = custom/text
# content = ""
# content-background = ${config.colorScheme.palette.base00-alt}
# content-foreground = ${config.colorScheme.palette.base01-alt}
# content-padding = 2
# click-left = sh ~/.scripts/rofi_launcher.sh

# [module/bluetooth]
# type = custom/script
# interval = 1
# format-background = ${config.colorScheme.palette.base00}
# format-foreground = ${config.colorScheme.palette.base01}
# format-padding = 2
# exec = ~/.config/polybar/scripts/bluetooth.zsh

"module/scrot" = {
type = "custom/text";
content = "";
content-background = "${config.colorScheme.palette.base00}";
content-foreground = "${config.colorScheme.palette.base01}";
content-padding = 2;
click-left = "~/.config/polybar/scripts/scrot.sh";
};

# [module/powermenu]
# type = custom/text
# content = ""
# content-background = ${config.colorScheme.palette.base00}
# content-foreground = ${config.colorScheme.palette.base01}
# content-padding = 2
# click-left = rofi -show power-menu -modi power-menu:~/.config/rofi/scripts/rofi-power-menu -theme ~/.config/rofi/themes/beat.rasi

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

}

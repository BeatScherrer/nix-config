{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.hyprlandNoctalia;

  # Gravel pit color scheme (matching herbstluftwm)
  colors = {
    active = "de935f"; # yellow/orange
    inactive = "101010";
    urgent = "a54242"; # red
    normal = "323232";
    background = "212121";
    foreground = "c7c7c7";
  };

  # Virtual monitor split script
  virtualMonitorScript = pkgs.writeShellScriptBin "hypr-virtual-monitors" ''
    #!/usr/bin/env bash
    # Virtual monitor split layouts for ultra-wide displays
    # Mimics herbstluftwm's layout system

    MONITOR="''${HYPR_MONITOR:-DP-5}"
    RESOLUTION="''${HYPR_RESOLUTION:-7680x2160}"
    REFRESH="''${HYPR_REFRESH:-240}"

    # Parse resolution
    WIDTH=$(echo "$RESOLUTION" | cut -d'x' -f1)
    HEIGHT=$(echo "$RESOLUTION" | cut -d'x' -f2)

    remove_virtual_monitors() {
      # Remove all virtual monitors and restore physical
      hyprctl keyword monitor "$MONITOR,disable"
      hyprctl keyword monitor "VMON-L,disable" 2>/dev/null || true
      hyprctl keyword monitor "VMON-C,disable" 2>/dev/null || true
      hyprctl keyword monitor "VMON-R,disable" 2>/dev/null || true
      sleep 0.1
      hyprctl keyword monitor "$MONITOR,''${RESOLUTION}@''${REFRESH},0x0,1"
    }

    create_split() {
      local left_pct=$1
      local center_pct=$2
      local right_pct=$3

      # Calculate pixel widths
      local left_w=$((WIDTH * left_pct / 100))
      local center_w=$((WIDTH * center_pct / 100))
      local right_w=$((WIDTH * right_pct / 100))

      # Calculate x offsets
      local center_x=$left_w
      local right_x=$((left_w + center_w))

      # Disable physical monitor first
      hyprctl keyword monitor "$MONITOR,disable"

      # Create virtual monitors
      hyprctl keyword monitor "desc:VMON-L,''${left_w}x''${HEIGHT}@''${REFRESH},0x0,1"
      hyprctl keyword monitor "desc:VMON-C,''${center_w}x''${HEIGHT}@''${REFRESH},''${center_x}x0,1"
      hyprctl keyword monitor "desc:VMON-R,''${right_w}x''${HEIGHT}@''${REFRESH},''${right_x}x0,1"

      echo "Created virtual monitors: $left_pct/$center_pct/$right_pct"
    }

    case "''${1:-none}" in
      30-40-30|30/40/30)
        remove_virtual_monitors
        create_split 30 40 30
        ;;
      25-50-25|25/50/25)
        remove_virtual_monitors
        create_split 25 50 25
        ;;
      20-60-20|20/60/20)
        remove_virtual_monitors
        create_split 20 60 20
        ;;
      none|reset|single)
        remove_virtual_monitors
        echo "Restored single monitor"
        ;;
      toggle)
        # Cycle through layouts
        CURRENT=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[0].name')
        if [[ "$CURRENT" == "VMON-"* ]]; then
          remove_virtual_monitors
        else
          create_split 25 50 25
        fi
        ;;
      *)
        echo "Usage: hypr-virtual-monitors [30-40-30|25-50-25|20-60-20|none|toggle]"
        exit 1
        ;;
    esac
  '';

  # Scratchpad script (mimics herbstluftwm scratchpad)
  scratchpadScript = pkgs.writeShellScriptBin "hypr-scratchpad" ''
    #!/usr/bin/env bash
    hyprctl dispatch togglespecialworkspace scratchpad
  '';

in
{
  # Note: No hyprpaper import - noctalia handles wallpapers
  imports = [
    ../noctalia/noctalia.nix
    ../rofi/rofi.nix
    ../dunst/dunst.nix
  ];

  options.hyprlandNoctalia = {
    enable = mkEnableOption "hyprland with noctalia shell (herbstluftwm-style)";

    monitor = mkOption {
      type = types.str;
      default = "DP-5,7680x2160@240,0x0,1";
      description = "Primary monitor configuration";
    };

    gapsOut = mkOption {
      type = types.str;
      default = "80, 20, 20, 20";
      description = "Outer gaps (top, right, bottom, left) - top is larger for noctalia bar";
    };
  };

  config = mkIf cfg.enable {
    noctalia.enable = true;

    home.packages = with pkgs; [
      virtualMonitorScript
      scratchpadScript
      wl-clipboard
      grim
      slurp
      grimblast
      playerctl
      brightnessctl
      swaynotificationcenter
      jq
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        # Autostart
        "exec-once" = [
          "noctalia-shell"
          "dunst"
        ];

        # Variables (matching herbstluftwm)
        "$mod" = "SUPER";
        "$terminal" = "ghostty";
        "$fileManager" = "nautilus";
        "$browser" = "librewolf";

        # Monitor configuration
        "monitor" = cfg.monitor;

        # General settings
        general = {
          gaps_in = 5;
          gaps_out = cfg.gapsOut;
          border_size = 5;
          "col.active_border" = "rgba(${colors.active}ff)";
          "col.inactive_border" = "rgba(${colors.inactive}cc)";
          layout = "dwindle";
          allow_tearing = false;
        };

        # Decoration (matching herbstluftwm theme)
        decoration = {
          rounding = 0;
        };

        # Animations
        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };

        # Dwindle layout settings
        dwindle = {
          pseudotile = true;
          preserve_split = true;
          force_split = 2;
        };

        # Master layout settings (alternative)
        master = {
          new_status = "master";
        };

        # Misc settings
        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
        };

        # Input settings
        input = {
          kb_layout = "us";
          kb_options = "compose:ralt";
          follow_mouse = 1;
          sensitivity = 0;
        };

        # ============================================
        # KEY BINDINGS (matching herbstluftwm)
        # ============================================
        bind = [
          # Session control
          "$mod SHIFT, Q, exit"
          "$mod SHIFT, R, exec, hyprctl reload"

          # Window control
          "$mod, W, killactive"
          "$mod, M, fullscreen, 0"
          "$mod SHIFT, F, togglefloating"
          "$mod, P, pseudo"

          # Applications
          "$mod, Return, exec, $terminal"
          "$mod, F, exec, $fileManager"
          "$mod, E, exec, evolution"
          "$mod, B, exec, $browser"
          "$mod, Space, exec, rofi -modi drun -show drun"

          # Focus movement (vim keys)
          "$mod, H, movefocus, l"
          "$mod, J, movefocus, d"
          "$mod, K, movefocus, u"
          "$mod, L, movefocus, r"

          # Focus movement (arrow keys)
          "$mod, Left, movefocus, l"
          "$mod, Down, movefocus, d"
          "$mod, Up, movefocus, u"
          "$mod, Right, movefocus, r"

          # Window movement (vim keys)
          "$mod SHIFT, H, movewindow, l"
          "$mod SHIFT, J, movewindow, d"
          "$mod SHIFT, K, movewindow, u"
          "$mod SHIFT, L, movewindow, r"

          # Window movement (arrow keys)
          "$mod SHIFT, Left, movewindow, l"
          "$mod SHIFT, Down, movewindow, d"
          "$mod SHIFT, Up, movewindow, u"
          "$mod SHIFT, Right, movewindow, r"

          # Scratchpad
          "$mod, Minus, togglespecialworkspace, scratchpad"
          "$mod SHIFT, Minus, movetoworkspace, special:scratchpad"

          # Workspace switching
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"

          # Move window to workspace
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"

          # Cycle workspaces (matching herbstluftwm period/comma)
          "$mod, Period, workspace, e+1"
          "$mod, Comma, workspace, e-1"

          # Cycle windows
          "$mod, Tab, cyclenext"
          "$mod SHIFT, Tab, cyclenext, prev"
          "$mod, C, cyclenext"

          # Monitor cycling
          "$mod, BackSpace, focusmonitor, +1"

          # Jump to urgent
          "$mod, I, focusurgentorlast"

          # Layout controls
          "$mod SHIFT, Space, togglesplit"

          # Splitting (create new splits like herbstluftwm)
          "$mod, U, layoutmsg, preselect d"
          "$mod, O, layoutmsg, preselect r"
          "$mod, Y, layoutmsg, preselect l"

          # Screenshots
          "$mod, Print, exec, grimblast copy area"
          ", Print, exec, grimblast copy screen"

          # Virtual monitor layouts (herbstluftwm-style splits)
          "ALT, 1, exec, hypr-virtual-monitors 30-40-30"
          "ALT, 2, exec, hypr-virtual-monitors 25-50-25"
          "ALT, 3, exec, hypr-virtual-monitors 20-60-20"
          "ALT, 0, exec, hypr-virtual-monitors none"
          "ALT, grave, exec, hypr-virtual-monitors toggle"
        ];

        # Resize bindings (matching herbstluftwm Ctrl+hjkl)
        binde = [
          "$mod CTRL, H, resizeactive, -40 0"
          "$mod CTRL, J, resizeactive, 0 40"
          "$mod CTRL, K, resizeactive, 0 -40"
          "$mod CTRL, L, resizeactive, 40 0"
          "$mod CTRL, Left, resizeactive, -40 0"
          "$mod CTRL, Down, resizeactive, 0 40"
          "$mod CTRL, Up, resizeactive, 0 -40"
          "$mod CTRL, Right, resizeactive, 40 0"
        ];

        # Mouse bindings
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
          "$mod, mouse:274, togglefloating" # Middle click
        ];

        # Media keys (locked bindings)
        bindl = [
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPause, exec, playerctl play-pause"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioPrev, exec, playerctl previous"
        ];

        # Volume/brightness (repeatable locked bindings)
        bindel = [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ", XF86MonBrightnessUp, exec, brightnessctl s 10%+"
          ", XF86MonBrightnessDown, exec, brightnessctl s 10%-"
        ];

        # ============================================
        # WINDOW RULES (matching herbstluftwm)
        # ============================================
        windowrulev2 = [
          # Floating windows
          "float, class:^(pavucontrol)$"
          "float, class:^(blueman-manager)$"
          "float, class:^(gnuplot_qt)$"
          "float, class:^(.blueman-manager-wrapped)$"

          # Gaming apps (managed/tiled)
          "tile, class:^(steam)$"
          "tile, class:^(Steam)$"
          "tile, class:^(lutris)$"

          # Dialog windows
          "float, title:^(Open File)$"
          "float, title:^(Save File)$"
          "float, title:^(Confirm)$"

          # Picture-in-picture
          "float, title:^(Picture-in-Picture)$"
          "pin, title:^(Picture-in-Picture)$"
          "size 640 360, title:^(Picture-in-Picture)$"

          # Scratchpad styling
          "float, class:^(scratchpad)$"
          "size 80% 80%, class:^(scratchpad)$"
          "center, class:^(scratchpad)$"
        ];

      };

      extraConfig = ''
        decoration {
          blur {
            enabled = true
            size = 3
            passes = 1
          }

          shadow {
            enabled = true
            range = 4
            render_power = 3
            color = rgba(1a1a1aee)
          }
        }

      '';
    };
  };
}

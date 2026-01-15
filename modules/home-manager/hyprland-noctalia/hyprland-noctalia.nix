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
      default = "5";
      description = "Outer gaps";
    };
  };

  config = mkIf cfg.enable {
    noctalia.enable = true;

    home.packages = with pkgs; [
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
          "$mod, Space, exec, noctalia-shell -t launcher"

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

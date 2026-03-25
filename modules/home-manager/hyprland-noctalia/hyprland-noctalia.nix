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
      type = types.listOf types.str;
      default = [ ",preferred,auto,1" ];
      description = "Monitor configurations (list of Hyprland monitor strings)";
    };

    gapsOut = mkOption {
      type = types.str;
      default = "5";
      description = "Outer gaps";
    };

    workspace = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Workspace-to-monitor bindings (list of Hyprland workspace strings)";
    };
  };

  config = mkIf cfg.enable {
    noctalia.enable = true;

    home.packages = with pkgs; [
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
        ];

        # Variables (matching herbstluftwm)
        "$mod" = "SUPER";
        "$terminal" = "ghostty";
        "$fileManager" = "nautilus";
        "$browser" = "librewolf";

        # Monitor configuration
        "monitor" = cfg.monitor;

        # Workspace-to-monitor bindings
        "workspace" = cfg.workspace ++ [
          "special:scratchpad, gapsout:30"
        ];

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
          dim_special = 0.8;
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
            "specialWorkspace, 1, 1, default, slidevert"
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

        # Window group (stacking) settings
        group = {
          "col.border_active" = "rgba(${colors.active}ff)";
          "col.border_inactive" = "rgba(${colors.inactive}cc)";
          groupbar = {
            enabled = true;
            font_size = 10;
            height = 14;
            render_titles = true;
            "col.active" = "rgba(${colors.active}ff)";
            "col.inactive" = "rgba(${colors.normal}cc)";
          };
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
          "$mod, Space, exec, noctalia-shell ipc call launcher toggle"

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

          # Window groups (stacking/tabbing)
          "$mod, T, togglegroup"
          "$mod, Next, changegroupactive, f"    # PageDown
          "$mod, Prior, changegroupactive, b"   # PageUp
          "$mod CTRL, T, moveoutofgroup"
          "$mod SHIFT, H, movewindoworgroup, l"
          "$mod SHIFT, J, movewindoworgroup, d"
          "$mod SHIFT, K, movewindoworgroup, u"
          "$mod SHIFT, L, movewindoworgroup, r"
          "$mod, G, lockactivegroup, toggle"

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

        # Floating windows
        "windowrule[pavucontrol]" = "float:true, class:^(pavucontrol)$";
        "windowrule[blueman]" = "float:true, class:^(blueman-manager)$";
        "windowrule[gnuplot]" = "float:true, class:^(gnuplot_qt)$";
        "windowrule[blueman-wrapped]" = "float:true, class:^(.blueman-manager-wrapped)$";

        # Gaming apps (managed/tiled)
        "windowrule[steam]" = "tile:true, class:^(steam)$";
        "windowrule[Steam]" = "tile:true, class:^(Steam)$";
        "windowrule[lutris]" = "tile:true, class:^(lutris)$";

        # Dialog windows
        "windowrule[open-file]" = "float:true, title:^(Open File)$";
        "windowrule[save-file]" = "float:true, title:^(Save File)$";
        "windowrule[confirm]" = "float:true, title:^(Confirm)$";

        # Picture-in-picture
        "windowrule[pip]" = "float:true, pin:true, size:640 360, title:^(Picture-in-Picture)$";




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

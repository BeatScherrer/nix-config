{ ... }:
{
  imports = [
    ../../home-manager/home.nix
    ../../modules/home-manager/work/mtr/mtr.nix
    ../../modules/home-manager/work/unlimited-booking/unlimited-booking.nix
    ../../modules/home-manager/vscode/vscode.nix
    ../../modules/home-manager/themes/gravel_pit.nix
  ];

  # NOTE: only host-specific options should be set here. Common options belong to the imported home.nix.

  # gpwm session shell is inherited from the system config (osConfig.gpwm.shell,
  # set in hosts/legion/configuration.nix) — no need to repeat it here.

  # gpwm layout + per-output workspace assignment. Written to
  # ~/.config/gpwm/config.toml by the upstream home module (enabled via the
  # shared modules/home-manager/gpwm/gpwm.nix), which gpwm reads in preference
  # to the system /etc config. Common keybindings live in that shared module.
  #
  # Start every workspace with a single full-width leaf instead of the upstream
  # 25/50/25 three-column default. The leaf is "horizontal" so additional
  # windows stack top-to-bottom, each spanning the full width.
  programs.gpwm.settings = {
    default-layout = "fullwidth";
    layout.fullwidth.leaf = "horizontal";

    # Per-output workspace ownership, modes, and left-to-right placement:
    # EmbeddedDisplayPort-1 (left) | DisplayPort-3 (middle) | HDMIA-1 (right).
    # Once any [output] table exists gpwm requires workspaces 1..9 to be
    # claimed exactly once, so all three connected monitors are declared here.
    # DMS can't set gpwm's mode/position (it only drives niri/hyprland), so
    # configure it declaratively. (Requires a gpwm build with `[output.X]
    # mode` + `relative-to` support.)
    output."EmbeddedDisplayPort-1" = {
      workspaces = [
        7
        8
        9
      ];
      mode = "2560x1600@165";
    };
    output."DisplayPort-3" = {
      workspaces = [
        1
        2
        3
      ];
      mode = "4096x2160@60";
      relative-to.right-of = "EmbeddedDisplayPort-1";
      scale = 1.25;
    };
    output."HDMIA-1" = {
      workspaces = [
        4
        5
        6
      ];
      mode = "2560x1440@75";
      relative-to.right-of = "DisplayPort-3";
    };
  };

  # Docked monitor layout (Wayland names)
  # eDP-1 = laptop, DP-3 = LG 4K (via dock), HDMI-A-1 = ASUS PB277 (direct HDMI)
  hyprlandNoctalia.monitor = [
    "eDP-1, 2560x1600@165, 0x0, 1"
    "DP-3, 4096x2160@60, 2560x0, 1.333"
    "HDMI-A-1, 2560x1440@75, 5632x0, 1" # x = 2560 (eDP-1) + 4096/1.333 (DP-3 scaled)
  ];

  hyprlandNoctalia.workspace = [
    "1, monitor:DP-3, default:true"
    "2, monitor:DP-3"
    "3, monitor:DP-3"
    "4, monitor:HDMI-A-1, default:true"
    "5, monitor:HDMI-A-1"
    "6, monitor:HDMI-A-1"
    "7, monitor:eDP-1, default:true"
    "8, monitor:eDP-1"
    "9, monitor:eDP-1"
  ];
}

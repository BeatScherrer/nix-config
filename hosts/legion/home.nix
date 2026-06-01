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

  # gpwm session shell: use DankMaterialShell instead of the noctalia default.
  # Must be set on the home-manager side too — the system module's gpwm.shell
  # only drives the launcher command; this one selects the systemd user service
  # (dms-shell vs noctalia-shell) bound to gpwm-session.target.
  gpwm.shell = "dms";

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

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

  # Docked monitor layout (Wayland names)
  # eDP-1 = laptop, DP-4 = LG 4K, DP-3 = third monitor
  hyprlandNoctalia.monitor = [
    "eDP-1, 2560x1600@165, 0x0, 1"
    "DP-4, 4096x2160@60, 2560x0, 1.333"
    "DP-3, 2560x1440@75, 6656x0, 1"
  ];

  hyprlandNoctalia.workspace = [
    "1, monitor:DP-4, default:true"
    "2, monitor:DP-4"
    "3, monitor:DP-4"
    "4, monitor:DP-3, default:true"
    "5, monitor:DP-3"
    "6, monitor:DP-3"
    "7, monitor:eDP-1, default:true"
    "8, monitor:eDP-1"
    "9, monitor:eDP-1"
  ];
}

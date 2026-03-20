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
  # eDP-1 = laptop (was DP-4 in X11), DP-3 = LG 4K (was DP-2.3), DP-? = third monitor (was DP-2.1)
  # TODO: verify third monitor Wayland name once connected
  hyprlandNoctalia.monitor = [
    "eDP-1, 2560x1600@165, 0x0, 1"
    "DP-3, 4096x2160@60, 2560x0, 1.333"
    # "DP-X, 2560x1440@75, 6656x0, 1"  # uncomment and fix name when third monitor is identified
  ];
}

{ ... }:
{
  imports = [
    ../../home-manager/home.nix
    ../../modules/home-manager/vscode/vscode.nix
    ../../modules/home-manager/work/unlimited-booking/unlimited-booking.nix
    ../../modules/home-manager/work/mtr/mtr.nix
    ../../modules/home-manager/work/shetec/shetec.nix
    ../../modules/home-manager/themes/gravel_pit.nix
  ];

  # NOTE: only host-specific options should be set here. Common options belong to the imported home.nix.

  # gpwm session shell: use DankMaterialShell instead of the noctalia default.
  gpwm.shell = "dms";

  # gpwm per-output settings. Written to ~/.config/gpwm/config.toml by the
  # upstream home module (enabled via the shared modules/home-manager/gpwm/gpwm.nix),
  # which gpwm reads in preference to the system /etc config. Common keybindings
  # live in that shared module.
  #
  # trident's single DisplayPort-3 monitor at 1.25x scale. Once any [output]
  # table exists gpwm requires workspaces 1..9 to be claimed exactly once, so
  # this one output owns them all. DMS can't set gpwm's scale (it only drives
  # niri/hyprland), so configure it declaratively here.
  programs.gpwm.settings.output."DisplayPort-3" = {
    workspaces = [
      1
      2
      3
      4
      5
      6
      7
      8
      9
    ];
    scale = 1.25;
  };

  # Scratchpad overlay spans 45% of the output width (height stays at the 0.8
  # default). Fraction in (0, 1] of the focused output's usable area; live-
  # reloaded on config save.
  programs.gpwm.settings.general.scratchpad-width = 0.45;
}

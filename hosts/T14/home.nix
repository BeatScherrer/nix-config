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

  # gpwm layout. Written to ~/.config/gpwm/config.toml by the upstream home
  # module (enabled via the shared modules/home-manager/gpwm/gpwm.nix), which
  # gpwm reads in preference to the system /etc config. Common keybindings live
  # in that shared module.
  #
  # T14's 14" screen is too narrow for the upstream 25/50/25 three-column
  # default — start every workspace with a single full-width leaf instead.
  # The leaf is "horizontal" so additional windows tile side-by-side within
  # that full-width frame.
  programs.gpwm.settings = {
    default-layout = "fullwidth";
    layout.fullwidth.leaf = "horizontal";

    # Internal panel (eDP-1) is a 2880x1800 display that also advertises a
    # 120Hz mode. Scale it to 1.25 so UI is legibly sized at that resolution,
    # and pin the 120Hz mode (the connector's preferred mode is only 60Hz).
    # Once any [output.X] table exists, gpwm requires every workspace 1..9 to
    # be claimed exactly once — this laptop has a single output, so all nine
    # live here.
    output."eDP-1" = {
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
      mode = "2880x1800@120";
    };
  };
}

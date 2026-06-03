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
  # The leaf is "vertical" so additional windows stack top-to-bottom, each
  # still spanning the full width.
  programs.gpwm.settings = {
    default-layout = "fullwidth";
    layout.fullwidth.leaf = "vertical";
  };
}

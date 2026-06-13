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

  # gpwm session shell is inherited from the system config (osConfig.gpwm.shell,
  # set in hosts/T14/configuration.nix) — no need to repeat it here.

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

    # Natural (reverse) scrolling on the touchpad — content tracks the fingers.
    # gpwm applies this to every libinput device that supports it (touchpad and
    # any wheel mouse), and hot-reloads it on config save.
    input.natural-scroll = true;

    # Internal panel is a 2880x1800 display that also advertises a 120Hz mode.
    # Scale it to 1.25 so UI is legibly sized at that resolution, and pin the
    # 120Hz mode (the connector's preferred mode is only 60Hz).
    # Once any [output.X] table exists, gpwm requires every workspace 1..9 to
    # be claimed exactly once — this laptop has a single output, so all nine
    # live here.
    #
    # NB: gpwm/smithay names the connector "EmbeddedDisplayPort-1" (the long
    # form, as reported by `gpwm msg outputs` / `wlr-randr`), NOT the kernel
    # short name "eDP-1". Using "eDP-1" silently no-ops the whole table — scale
    # and mode get dropped and the workspaces bind to a phantom output. (legion
    # already uses the long form.)
    output."EmbeddedDisplayPort-1" = {
      scale = 1.25;
      mode = "2880x1800@120";
    };
  };
}

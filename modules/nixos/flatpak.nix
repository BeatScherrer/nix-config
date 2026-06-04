{ lib, ... }:
{
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  # Generic catch-all fallback. mkDefault so a host with a deliberate portal
  # policy (e.g. gpwm routes ScreenCast/Screenshot to wlr, default to gtk)
  # overrides it instead of conflicting.
  xdg.portal.config.common.default = lib.mkDefault "*";
}

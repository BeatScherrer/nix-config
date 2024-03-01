{ config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    hyprland
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    # if cursor becomes invisible.
    WLR_NO_HARDWARE_CURSOR = "1";
    # hint to electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  # hardware = {
  #   opengl.enable = true;
  #
  #   # most wayland compositors need this
  #   nvidia.modesetting.enable = true;
  # };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

}

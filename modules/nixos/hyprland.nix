{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    hyprland
    hyprpicker
    hyprcursor
    hyprlock
    hypridle
    hyprpaper
    kitty # TODO: remove if not used
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  users.users.beat.extraGroups = [
    "video"
    "render"
  ];

  services.displayManager = {
    gdm.enable = true;
    gdm.wayland = true;
  };

  environment.sessionVariables = {
    # if cursor becomes invisible.
    WLR_NO_HARDWARE_CURSOR = "1";
    # hint to electron apps to use wayland
    NIXOS_OZONE_WL = "1";
    # from https://wiki.hyprland.org/Nvidia/
    # LIBVA_DRIVER_NAME = "nvidia";
    # XDG_SESSION_TYPE = "wayland";
    # GBM_BACKEND = "nvidia-drm";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # boot.initrd.availableKernelModules = [
  #   "nvidia"
  #   "nvidia_modeset"
  #   "nvidia_uvm"
  #   "nvidia_drm"
  # ];
  # boot.kernelParams = [ "nvidia-drm.modeset=1" ];
}

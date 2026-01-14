{
  config,
  pkgs,
  user,
  lib,
  ...
}:
with lib;
let
  cfg = config.hyprland;
in
{
  options.hyprland = {
    enable = mkEnableOption "hyprland";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      hyprland
      hyprpicker
      hyprcursor
      hyprlock
      hypridle
      hyprpaper
    ];

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    users.users.${user}.extraGroups = [
      "video"
      "render"
    ];

    services.displayManager = {
      gdm.enable = true;
      gdm.wayland = true;
    };

    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSOR = "1";
      NIXOS_OZONE_WL = "1";
    };

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}

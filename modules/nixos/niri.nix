{
  config,
  pkgs,
  user,
  lib,
  ...
}:
with lib;
let
  cfg = config.niri;
in
{
  options.niri = {
    enable = mkEnableOption "niri";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      niri
      xwayland-satellite
      wl-clipboard
      grim
      slurp
      wlr-randr
      brightnessctl
      playerctl
      gnome-keyring
      gnome-online-accounts
      gnome.gvfs
      dbus
      blueman
      xdg-desktop-portal
      xdg-desktop-portal-gnome
    ];

    programs.niri = {
      enable = true;
    };

    users.users.${user}.extraGroups = [
      "video"
      "render"
    ];

    services.dbus.enable = true;

    services.displayManager = {
      gdm.enable = true;
      gdm.wayland = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    };

    services.gnome = {
      gnome-keyring.enable = true;
      gnome-settings-daemon.enable = true;
      evolution-data-server.enable = true;
      gnome-online-accounts.enable = true;
    };
    services.gvfs.enable = true;
    services.blueman.enable = true;

    security.pam.services.login.enableGnomeKeyring = true;
    security.polkit.enable = true;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}

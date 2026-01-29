{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.gnome;
in
{
  options.gnome = {
    enable = mkEnableOption "gnome";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gnome-session
      gnome-tweaks
      gnomeExtensions.pop-shell
      gnome-remote-desktop
      xorg.xev
      xorg.xhost
      xorg.xauth
      xorg.xeyes
      xorg.xinit
      xdg-desktop-portal-gtk
      mesa-demos
    ];

    services.xserver = {
      xkb.layout = "us";
      xkb.variant = "";
      xkb.options = "compose:ralt";
      enable = true;
      displayManager.sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset s off
        ${pkgs.xorg.xset}/bin/xset -dpms
      '';
    };

    services.desktopManager.gnome.enable = true;
    services.displayManager = {
      gdm.enable = true;
    };

    programs.dconf.profiles.gdm.databases = [
      {
        settings = {
          "org/gnome/settings-daemon/plugins/power" = {
            sleep-inactive-ac-type = "nothing";
            sleep-inactive-battery-type = "nothing";
          };
        };
      }
    ];

    xdg.portal.enable = true;
    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

    services.xrdp = {
      enable = true;
      openFirewall = true;
      defaultWindowManager = "${pkgs.gnome-remote-desktop}/bin/gnome-session";
    };
    networking.firewall.allowedTCPPorts = [ 3389 ];
    networking.firewall.allowedUDPPorts = [ 3389 ];
  };
}

{
  config,
  pkgs,
  pkgs-stable,
  lib,
  ...
}:
with lib;
let
  cfg = config.herbstluftwm;
in
{
  options.herbstluftwm = {
    enable = mkEnableOption "herbstluftwm";
  };

  config = mkIf cfg.enable {
    services.autorandr = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      pkgs-stable.herbstluftwm
      xorg.xev
      xorg.xauth
      xorg.xhost
      xorg.xeyes
      xorg.xinit
      xdotool
      gnome-keyring
      gnome-online-accounts
      gnome.gvfs
      dbus
      blueman
      xdg-desktop-portal
      xdg-desktop-portal-gtk
    ];

    services.xserver = {
      windowManager.herbstluftwm = {
        enable = true;
        package = pkgs-stable.herbstluftwm;
      };
      dpi = 140;
      enable = true;
      serverFlagsSection = ''
        Option "AllowIndirectGLX" "on"
      '';
      xkb.layout = "us";
      xkb.variant = "";
      xkb.options = "compose:ralt";

      displayManager = {
        sessionCommands = ''
          ${pkgs.xorg.xhost}/bin/xhost +local:
        '';
      };
    };

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

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
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

    programs.nm-applet.enable = true;
  };
}

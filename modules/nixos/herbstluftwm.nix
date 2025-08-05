# TODO: make this configurable for both setups

{ config, pkgs, ... }:
{
  services.autorandr = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    herbstluftwm
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
    xdg-desktop-portal-gtk # change this based on your DE
  ];

  services.xserver = {
    windowManager.herbstluftwm = {
      enable = true;
    };
    dpi = 140;
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
    xkb.options = "compose:ralt";

    displayManager = {
      sessionCommands = ''
        ${pkgs.xhost}/bin/xhost +local:          # allow container to use x
      '';
    };
  };

  services.displayManager = {
    gdm.enable = true;
  };

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
  services.gvfs.enable = true; # required for smb
  services.blueman.enable = true;

  security.pam.services.login.enableGnomeKeyring = true;

  programs.nm-applet.enable = true;
}

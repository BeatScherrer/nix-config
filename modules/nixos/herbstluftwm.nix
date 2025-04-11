{ config, pkgs, ... }:

{
  services.autorandr = { enable = true; };

  environment.systemPackages = with pkgs; [
    herbstluftwm
    xorg.xev
    xorg.xauth
    xorg.xhost
    xorg.xeyes
    xorg.xinit
    gnome-keyring
    gnome-online-accounts
    gnome.gvfs
    dbus
    blueman
  ];

  services.xserver = {
    windowManager.herbstluftwm = { enable = true; };
    dpi = 140;
    enable = true;
    xkb.layout = "us";
    xkb.variant = "";
    xkb.options = "compose:ralt";

    displayManager = {
      gdm = { enable = true; };

      # NOTE: another attempt to fix the odyssey g9 monitor issue... this one works
      sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset s off         # Disable screen saver
        ${pkgs.xorg.xset}/bin/xset -dpms         # Disable DPMS
      '';
    };
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

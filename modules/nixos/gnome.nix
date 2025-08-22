{ config, pkgs, ... }:
{
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
    displayManager = {
      gdm.enable = true;
      # NOTE: another attempt to fix the odyssey g9 monitor issue... this one works
      sessionCommands = ''
        ${pkgs.xorg.xset}/bin/xset s off         # Disable screen saver
        ${pkgs.xorg.xset}/bin/xset -dpms         # Disable DPMS
      '';
    };
    desktopManager.gnome.enable = true;
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # RDP
  services.xrdp = {
    enable = true;
    openFirewall = true;
    defaultWindowManager = "${pkgs.gnome-remote-desktop}/bin/gnome-session";
  };
  networking.firewall.allowedTCPPorts = [ 3389 ];
  networking.firewall.allowedUDPPorts = [ 3389 ];
}

{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gnome-session
    gnome-tweaks
    gnomeExtensions.pop-shell
    gnome-remote-desktop
  ];

  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager = {
      gdm.enable = true;
    };
  };

  # RDP
  services.xrdp = {
    enable = true;
    openFirewall = true;
    defaultWindowManager = "${pkgs.gnome-remote-desktop}/bin/gnome-session";
  };
  networking.firewall.allowedTCPPorts = [ 3389 ];
  networking.firewall.allowedUDPPorts = [ 3389 ];
}

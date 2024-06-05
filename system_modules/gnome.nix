{ config, pkgs, ... }:
{
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
    enable = true;
    desktopManager.gnome.enable = true;
    displayManager = {
      gdm.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
    gnomeExtensions.pop-shell
  ];
}
